defmodule IrchubWeb.PageController do
  use IrchubWeb, :controller
  @login_path "/users/log_in/"
  @homepage_path "/hub/"
  def login_path, do: @login_path
  def homepage_path, do: @homepage_path
  def home(conn, _params) do
    current_user = conn.assigns[:current_user]
    redir_path =
      if current_user == nil,
      do: @login_path,
      else: @homepage_path
    conn
    |> redirect(to: redir_path)
  end
end
