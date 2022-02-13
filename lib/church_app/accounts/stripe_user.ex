defmodule ChurchApp.Accounts.StripeUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stripe_users" do
    field :email, :string
    field :stripe_id, :string

    belongs_to :church, ChurchApp.Accounts.Church

    timestamps()
  end

  @doc false
  def changeset(stripe_user, attrs) do
    stripe_user
    |> cast(attrs, [:email, :stripe_id, :church_id])
    |> validate_required([:email, :stripe_id, :church_id])
    |> unique_constraint(:email)
  end
end
