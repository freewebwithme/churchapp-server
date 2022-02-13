defmodule ChurchApp.Repo.Migrations.CreateStripeUser do
  use Ecto.Migration

  def change do
    create table("stripe_users") do
      add :email, :string
      add :stripe_id, :string

      add :church_id, references("churches")

      timestamps()
    end

    create unique_index(:stripe_users, [:email])
  end
end
