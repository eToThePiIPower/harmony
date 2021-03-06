import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :harmony, :sql_sandbox, true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :harmony, Harmony.Repo,
  socket_dir: "/var/run/postgresql",
  database: "harmony_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Configure the database for Github Actions
if System.get_env("GITHUB_ACTIONS") do
  config :harmony, Harmony.Repo,
    socket_dir: nil, # must explicitly unset
    username: System.get_env("POSTGRES_USER"),
    password: System.get_env("POSTGRES_PASSWORD"),
    hostname: System.get_env("POSTGRES_HOSTNAME"),
    port: System.get_env("POSTGRES_PORT")
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :harmony, HarmonyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KApGo8MoBcUia8E/oQF+d47D4VsxH9wM2wlZ3l7HU7YITsOv990LDYNA7CVWsS3B",
  server: true

config :wallaby, driver: Wallaby.Chrome

# In test we don't send emails.
config :harmony, Harmony.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
