import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :domovik, Domovik.Repo,
  ## For TCP connection
  # hostname: "localhost",
  # username: "postgres",
  # password: "postgres",

  ## For UNIX socket connection
  # socket_dir: "/var/run/postgresql",
  # username: "someone",

  database: "domovik_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :domovik, DomovikWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "7CbI2KISn8bXoABIc+lVJdKKC+05YsHD47IUDAnwv6cOl7i156LdmXLVyp+qdjdE",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
