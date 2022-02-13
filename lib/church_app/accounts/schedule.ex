defmodule ChurchApp.Accounts.Schedule do
  use Ecto.Schema

  embedded_schema do
    field :service_name, :string
    field :service_time, :string
    field :order, :integer
  end
end
