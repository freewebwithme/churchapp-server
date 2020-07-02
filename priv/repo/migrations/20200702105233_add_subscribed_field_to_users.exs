defmodule ChurchApp.Repo.Migrations.AddSubscribedFieldToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :subscribed, :boolean, default: false
      add :stripe_id, :string
    end
  end
end
