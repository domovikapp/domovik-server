# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :domovik,
  ecto_repos: [Domovik.Repo]

# Configures the endpoint
config :domovik, DomovikWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DomovikWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Domovik.PubSub,
  live_view: [signing_salt: "XYSNdkbn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure POW
config :domovik, :pow,
  user: Domovik.Users.User,
  users_context: Domovik.Users,
  repo: Domovik.Repo,
  web_module: DomovikWeb,
  mailer_backend: DomovikWeb.Pow.Mailer,
  routes_backend: DomovikWeb.Pow.Routes,
  web_mailer_module: DomovikWeb

config :domovik,
  trial_length: 30,
  free_instance: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
