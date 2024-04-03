defmodule Irchub.Accounts.Social.Github do
  alias Ecto.UUID
  alias Irchub.Util
  def oauth_url do
    base_url = ~s(https://github.com/login/oauth/authorize)
    client_id = Util.global_context()[:github_client_id]
    if is_binary(client_id) && String.length(client_id) > 0 do
      state = UUID.generate() <> "-" <> UUID.generate()
      if Util.push_github_state(state) do
        {:ok, %{url: ~s(#{base_url}?client_id=#{client_id}&state=#{state}), state: state}}
      else
        {:err_invalid_state, %{}}
      end
    else
      {:err_invalid_client_id, %{}}
    end
  end
  def access_token_verify_state(code, state) do
    if Util.pop_github_state(state) do
      access_token(code, state)
    else
      nil
    end
  end
  def access_token(code, state \\ nil) do
    post_url = ~s(https://github.com/login/oauth/access_token)
    client_id = Util.global_context()[:github_client_id]
    client_secret = Util.global_context()[:github_client_secret]
    base_data = %{
      client_id: client_id,
      client_secret: client_secret,
      code: code,
    }
    post_data = if state == nil, do: base_data, else: Map.put(base_data, :state, state)

    resp = HTTPoison.post!(
      post_url,
      Poison.encode!(post_data),
      [{"Content-Type", "application/json"}]
    ).body
    Map.get(URI.decode_query(resp), "access_token")
  end
  def user_email(auth_token) do
    headers = [
      {"Authorization",  "bearer #{auth_token}"},
    ]
    resp = Poison.decode!(HTTPoison.get!(~s(https://api.github.com/user), headers).body)

    email = Map.get(resp, "email")
    email || ~s(#{:crypto.hash(:sha, Map.get(resp, "id") |> Integer.to_string(16)) |> Base.encode16 |> String.downcase}@github.irchub.local)
  end
end
