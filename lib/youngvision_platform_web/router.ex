defmodule YoungvisionPlatformWeb.Router do
  use YoungvisionPlatformWeb, :router

  import YoungvisionPlatformWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {YoungvisionPlatformWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", YoungvisionPlatformWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", YoungvisionPlatformWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:youngvision_platform, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: YoungvisionPlatformWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", YoungvisionPlatformWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{YoungvisionPlatformWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", YoungvisionPlatformWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Groups routes
    resources "/groups", GroupController
    post "/groups/:id/join", GroupController, :join
    post "/groups/:id/leave", GroupController, :leave

    # Controller-based post routes are now handled by LiveView

    live_session :require_authenticated_user,
      on_mount: [{YoungvisionPlatformWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/community/map", CommunityMapLive, :index

      # Calendar routes
      live "/community/calendar", CommunityCalendarLive, :index
      live "/community/calendar/new", CommunityCalendarLive, :new
      live "/community/calendar/:id", CommunityCalendarLive, :show
      live "/community/calendar/:id/edit", CommunityCalendarLive, :edit

      # Messaging routes
      live "/messages", MessagingLive, :index
      live "/messages/new", MessagingLive, :new
      live "/messages/:id", MessagingLive, :show

      # Posts routes with LiveView for real-time updates
      live "/", PostsLive, :index
      live "/posts", PostsLive, :index
      live "/posts/new", PostsLive, :new
      live "/posts/:id", PostsLive, :show

      # User profile routes
      live "/users/:id", UserProfileLive, :show
      live "/users/:id/edit", UserProfileLive, :edit
    end
  end

  scope "/", YoungvisionPlatformWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{YoungvisionPlatformWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
