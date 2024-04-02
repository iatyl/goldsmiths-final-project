defmodule IrchubWeb.SocialAuthGithubLive do
  use IrchubWeb, :live_view
  alias Irchub.Accounts.Social.Github

  def mount(_params, _session, socket) do
    {:ok, github_oauth_data} = Github.oauth_url()
    github_oauth_url = github_oauth_data.url
    {:ok, socket |> redirect(external: github_oauth_url)}
  end
end
