defmodule ChurchApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, Comeonin.Ecto.Password

    has_one :church, ChurchApp.Accounts.Church, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> unique_constraint(:email)
    |> validate_required([:name, :email, :password])
    |> validate_email_format()
    |> validate_length(:password, min: 6)
  end

  defp validate_email_format(changeset) do
    case EmailChecker.Check.Format.valid?(changeset.changes.email) do
      true ->
        changeset

      _ ->
        add_error(changeset, :email, "email is not valid")
    end
  end
end
