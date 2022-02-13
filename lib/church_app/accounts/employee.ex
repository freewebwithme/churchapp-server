defmodule ChurchApp.Accounts.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :name, :string
    field :position, :string
    field :profile_image, :string
    field :order, :integer

    belongs_to :church, ChurchApp.Accounts.Church
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:name, :position, :profile_image, :order, :church_id])
    |> validate_required([:name, :position])
  end
end
