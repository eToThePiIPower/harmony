defmodule Harmony.Repo do
  use Ecto.Repo,
    otp_app: :harmony,
    adapter: Ecto.Adapters.Postgres
end
