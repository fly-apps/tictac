# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tictac, TictacWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/03gdZfIExh2op5Xzm1A0YuYp5VlP4nGDUbX6yc2TpR3MY/K/LCk8h2mLjF9PXEC",
  render_errors: [view: TictacWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tictac.PubSub,
  live_view: [signing_salt: "wxN4jnnC"]

# Track which mix environment this is for since Mix isn't available in
# production releases.
config :tictac, :env, Mix.env()

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
