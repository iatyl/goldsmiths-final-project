defmodule IrchubWeb.PageController do
  use IrchubWeb, :controller

  def home(conn, _params) do
    current_user = conn.assigns[:current_user]
    redir_path =
      if current_user == nil,
      do: "/users/log_in/",
      else: "/hub/"
    conn
    |> redirect(to: redir_path)
  end
end
