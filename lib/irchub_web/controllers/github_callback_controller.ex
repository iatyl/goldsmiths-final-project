defmodule IrchubWeb.GithubCallbackController do
  use IrchubWeb, :controller

  alias Irchub.Accounts
  alias IrchubWeb.UserAuth
  alias Irchub.Accounts.Social.Github
  alias Ecto.UUID


  def callback(conn, _params) do
    code = conn.params["code"]
    state = conn.params["state"]
    access_token = Github.access_token_verify_state(code, state)
    if access_token == nil do
      conn
      |> put_flash(:error, "Invalid GitHub token")
      |> redirect(to: ~p"/users/log_in")
    else
      email = Github.user_email(access_token)
      user = Accounts.get_user_by_email(email)
      user = if user == nil, do: Accounts.register_user(
        %{email: email, password: UUID.generate()}
        ), else: {:ok, user}
      {:ok, user} = user
      conn
      |> put_flash(:info, "GitHub Sign-in was successful.")
      |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    end
  end

end
