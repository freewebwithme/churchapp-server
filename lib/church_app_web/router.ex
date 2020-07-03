defmodule ChurchAppWeb.Router do
  use ChurchAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
    plug ChurchAppWeb.Plugs.SetCurrentUser
  end

  #  scope "/", ChurchAppWeb do
  #    pipe_through :browser
  #
  #    get "/", PageController, :index
  #  end

  scope "/" do
    pipe_through(:api)

    forward("/api", Absinthe.Plug, schema: ChurchAppWeb.Schema)

    if Mix.env() == :dev do
      forward("/graphiql", Absinthe.Plug.GraphiQL,
        schema: ChurchAppWeb.Schema,
        socket: ChurchAppWeb.UserSocket
      )
    end
  end

  scope "/webhook", ChurchAppWeb do
    pipe_through(:api)

    get "/youtube", YoutubeController, :subscribe_confirm
    post "/youtube", YoutubeController, :handle_upload_notification

    post "/stripe/subscription-created", StripeWebhookController, :subscription_created
    post "/stripe/subscription-deleted", StripeWebhookController, :subscription_deleted
  end

  scope "/profile-image", ChurchAppWeb do
    pipe_through(:api)

    post "/upload", ProfileImageUploadController, :upload
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
    # If using Plug.Router, make sure to add the `to`
    # forward "/sent_emails", to: Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChurchAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  #  if Mix.env() in [:dev, :test] do
  #    import Phoenix.LiveDashboard.Router
  #
  #    scope "/" do
  #      pipe_through :browser
  #      live_dashboard "/dashboard", metrics: ChurchAppWeb.Telemetry
  #    end
  #  end
end
