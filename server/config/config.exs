# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :racquet_fun,
  ecto_repos: [RacquetFun.Repo],
  generators: [binary_id: true]

config :racquet_fun, RacquetFun.Repo, migration_primary_key: false

# Configures the endpoint
config :racquet_fun, RacquetFunWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: RacquetFunWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: RacquetFun.PubSub,
  live_view: [signing_salt: "x3B/ibkr"]

# Configures the auth guardian (JWT)
config :racquet_fun, RacquetFun.Auth.Guardian,
  issuer: "racquet_fun",
  secret_key: "XSqbAHgpRCYzVbAlr+k1kqXVgTZzwvNWPB82Ie3lQFXY/bXWYQJ/i7OBgtGb28sT"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :racquet_fun, RacquetFun.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: {RacquetFunUtil.Logger.Logfmt, :format},
  metadata: [
    # app
    :application,
    :module,
    :function,
    :file,
    :line,
    # web
    :method,
    :path,
    :status_code,
    :elapsed
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Disable default logger in Phoenix
config :phoenix, :logger, false

# Config the message bus topics to register
config :event_bus,
  topics: [
    :user_signed_up,
    :user_activated
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
