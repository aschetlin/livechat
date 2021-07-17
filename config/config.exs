# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :livechat, LivechatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mw1h/N+X2FAU2b1C9a05d9vpq5tUWpUro5Z53oem1K9cbFeSies6fM+VHKFlMb8E",
  render_errors: [view: LivechatWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Livechat.PubSub,
  live_view: [signing_salt: "pix0JUa5"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
