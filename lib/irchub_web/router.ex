defmodule IrchubWeb.Router do
  use IrchubWeb, :router

  import IrchubWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IrchubWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug IrchubWeb.Plugs.FetchCookieConsentStatus
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IrchubWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", IrchubWeb do
    # pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:irchub, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IrchubWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
  scope "/", IrchubWeb do
    pipe_through [:browser]
    get "/cookie_consent/agree", CookieConsentController, :agree
  end

  ## Authentication routes
  scope "/", IrchubWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{IrchubWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/social_auth/github", SocialAuthGithubLive, :new
      # live "/users/reset_password", UserForgotPasswordLive, :new
      # live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    get "/social_auth/github_callback", GithubCallbackController, :callback
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", IrchubWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{IrchubWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/clients", ClientLive.Index, :index
      live "/clients/new", ClientLive.Index, :new
      live "/clients/:id/edit", ClientLive.Index, :edit
      live "/clients/:id", ClientLive.Show, :show
      live "/clients/:id/show/edit", ClientLive.Show, :edit
      live "/hub", HubLive.Index, :index
      live "/clients/:client_id/channels/:channel", HubLive.Channel, :index
      live "/clients/:client_id/nicks/:nick", HubLive.DirectMessage, :index
    end
  end

  scope "/", IrchubWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{IrchubWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
