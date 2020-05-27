defmodule ChurchApp.Repo do
  use Ecto.Repo,
    otp_app: :church_app,
    adapter: Ecto.Adapters.Postgres
end
