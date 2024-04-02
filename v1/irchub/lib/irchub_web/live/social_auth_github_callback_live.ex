defmodule IrchubWeb.SocialAuthGithubCallbackLive do
  use IrchubWeb, :live_view
  alias Irchub.Util
  alias Irchub.Accounts.Social.Github

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
          <.link class="w-full focus:outline-none text-white bg-purple-700 hover:bg-purple-800 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg px-5 py-2.5 dark:bg-purple-600 dark:hover:bg-purple-700 dark:focus:ring-purple-900"
           href={~p"/social_auth/github"}>Sign in with GitHub</.link>
        </:actions>

      </.simple_form>

    </div>
    """
  end

  def mount(%{"code" => code, "state" => state}, _session, socket) do
    if Util.pop_github_state(state) == false do
      {:ok, assign(socket, message: "Could not sign you in. Reason: Invalid client state.")}
    else
      access_token = Github.access_token(code, state)
      if access_token == nil do
        {:ok, assign(socket, message: "Could not sign you in. Reason: Invalid access token.")}
      else
        {:ok, socket}
      end
    end
  end
end
