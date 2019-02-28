# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :instaghub,
  ecto_repos: [Instaghub.Repo]

# Configures the endpoint
config :instaghub, InstaghubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "078VBgbhyElPf97JQ8GaWe8Cn0gwDFIEQ5H5p7ITAqAzsTUUAJKy0O0NH3Gzj89T",
  render_errors: [view: InstaghubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Instaghub.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :instaghub,
  redis_uri: "redis://localhost:6379",
  redis_name: :redis_ins,
  redis_ttl: 120
