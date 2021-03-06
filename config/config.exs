# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :church_app,
  ecto_repos: [ChurchApp.Repo]

# Configures the endpoint
config :church_app, ChurchAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: ChurchAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ChurchApp.PubSub,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")]

config :church_app, ChurchApp.Mailer,
  adapter: Bamboo.MailgunAdapter,
  # {:system, "MAILGUN_API"},
  api_key: System.get_env("MAILGUN_API"),
  # {:system, "MAILGUN_DOMAIN_NAME"},
  domain: System.get_env("MAILGUN_DOMAIN_NAME"),
  # {:system, "MAILGUN_BASE_URI"}
  base_uri: System.get_env("MAILGUN_BASE_URI")

# config :stripity_stripe, api_key: fn -> System.get_env("MASTER_STRIPE_API_KEY") end

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: {:system, "AWS_REGION"}

config :stripity_stripe, api_key: fn -> System.get_env("STRIPE_SECRET") end

config :recaptcha,
  public_key: {:system, "RECAPTCHA_PUBLIC_KEY"},
  secret: {:system, "RECAPTCHA_PRIVATE_KEY"},
  json_library: Jason

config :one_signal,
  user_auth_key: System.get_env("ONE_SIGNAL_USER_AUTH_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
