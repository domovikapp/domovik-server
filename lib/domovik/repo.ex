defmodule Domovik.Repo do
  use Ecto.Repo,
    otp_app: :domovik,
    adapter: Ecto.Adapters.Postgres
end
