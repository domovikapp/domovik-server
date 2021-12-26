defmodule DomovikWeb.Router do
  use DomovikWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  import Plug.BasicAuth

  @free_instance Application.compile_env(:domovik, :free_instance) || false

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Pow.Plug.Session, otp_app: :domovik
  end

  pipeline :admin do
    plug :basic_auth,
      username: Application.get_env(:domovik, :admin_username, "admin"),
      password: Application.get_env(:domovik, :admin_password, "123")
  end

  pipeline :stripe_webhook do
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug DomovikWeb.APIAuthPlug, otp_app: :domovik
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: DomovikWeb.APIAuthErrorHandler
    plug DomovikWeb.SubscribedPlug
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
  end

  # Non-authenticated path
  scope "/", DomovikWeb do
    pipe_through :browser

    unless @free_instance do
      # Stripe integration
      ## Redirected there when payment succeeded
      get "/subscribe/success/", UserController, :subscription_success
      ## Redirected there when payment failed
      get "/subscribe/cancel", UserController, :subscription_cancel
      ## Returns a subscription object
      get "/subscription/:type", UserController, :get_subscription
    end
  end

  unless @free_instance do
    scope "/", DomovikWeb do
      pipe_through :stripe_webhook

      post "/stripe/hooks", StripeController, :webhooks
    end
  end

  # Authenticated paths
  scope "/", DomovikWeb do
    pipe_through [:browser, :protected]

    # Browsers management
    resources "/browsers", BrowserController, except: [:create]

    # Reading lists
    scope "/lists" do
      resources "/", ListController
      get "/:id/:link_id/consume", ListController, :consume_link
    end

    # Bookmarks management
    scope "/bookmarks" do
      get "/", BookmarksController, :index
      delete "/:id", BookmarksController, :delete
    end

    scope "/settings" do
      get "/", UserController, :settings
      post "/news", UserController, :news
      get "/billing", UserController, :stripe_portal

      # Download personal data
      scope "/download" do
        get "/bookmarks", UserController, :download_bookmarks
        get "/lists", UserController, :download_reading_lists
        get "/tabs", UserController, :download_tabs
      end
    end
  end

  scope "/api/v1", DomovikWeb.Api.V1 do
    pipe_through :api

    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  scope "/api/v1", DomovikWeb.Api.V1, as: :api do
    pipe_through [:api, :api_protected]

    # Browsers management
    resources "/browsers", BrowserController
    post "/browsers/:id/command", BrowserController, :new_command
    get "/browsers/:id/command", BrowserController, :get_pending

    # Tabs management
    post "/browsers/tabs", BrowserController, :sync_tabs
    patch "/browsers/:uuid/tabs", BrowserController, :upsert_tab
    delete "/browsers/:uuid/tabs/:tab_session_id", BrowserController, :delete_tab

    # Lists management
    get "/lists", ListController, :index
    post "/lists", ListController, :create
    ## Lists content management
    get "/lists/:id", ListController, :show
    post "/lists/:id", ListController, :add_link
    delete "/lists/:id/:link_id", ListController, :delete_link

    # Bookmarks management
    resources "/bookmarks", BookmarksController, except: [:update, :new, :edit]
    put "/bookmarks", BookmarksController, :sync_all
    get "/bookmarks/:uuid", BookmarksController, :index_others
  end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    if Mix.env() in [:dev, :test] do
      pipe_through :browser
    else
      pipe_through [:browser, :admin]
    end

    live_dashboard "/dashboard",
      metrics: DomovikWeb.Telemetry,
      ecto_repos: [Domovik.Repo]
  end

  if Mix.env() in [:dev, :test] do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
