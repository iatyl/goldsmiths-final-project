defmodule Irchub.Accounts.Social.Github do
  alias Ecto.UUID
  alias Irchub.Util
  def oauth_url do
    base_url = ~s(https://github.com/login/oauth/authorize)
    client_id = Util.global_context()[:github_client_id]
    state = UUID.generate()
    {:ok, %{url: ~s(#{base_url}?client_id=#{client_id}&state=#{state}), state: state}}
  end
  def access_token(code, state \\ nil) do
    post_url = ~s(https://github.com/login/oauth/access_token)
    client_id = Util.global_context()[:github_client_id]
    client_secret = Util.global_context()[:github_client_secret]
    post_data = %{
      client_id: client_id,
      client_secret: client_secret,
      code: code,
    }
    HTTPoison.post(post_url, "{\"body\": \"test\"}", [{"Content-Type", "application/json"}])
  end
end
