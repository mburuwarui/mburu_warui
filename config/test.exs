import Config
config :amboseli, token_signing_secret: "vsY9IVZAWvgNQdpXO59TvEGZ3FY+CWYs"
config :ash, disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :amboseli, Amboseli.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "amboseli_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :amboseli, AmboseliWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/LOoM3AknTw6Y6sSRosBIkx92nqkk1+p8pTaDeRA4GEsOB53EVvwZEe+0cbxIz8n",
  server: false

# In test we don't send emails.
config :amboseli, Amboseli.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
