import Config
config :bubble, Oban, testing: :manual

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bubble, Bubble.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bubble_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bubble, BubbleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "o/DWz2yNbq3ZjQBvo0/f8TiyAgv+jDryMCRYlJzsgi1V2+JLByup6GMrG3IrTn80",
  server: false

# In test we don't send emails
config :bubble, Bubble.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :bubble,
  rss_client_req_options: [
    plug: {Req.Test, Bubble.Sources.RSSClient},
    retry: false
  ],
  http_client_req_options: [
    plug: {Req.Test, Bubble.Sources.HttpClient},
    retry: false
  ]
