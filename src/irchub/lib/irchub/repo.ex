defmodule Irchub.Repo do
  use Ecto.Repo,
    otp_app: :irchub,
    adapter: Ecto.Adapters.Postgres
end
