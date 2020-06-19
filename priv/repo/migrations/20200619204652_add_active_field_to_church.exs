defmodule ChurchApp.Repo.Migrations.AddActiveFieldToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :active, :boolean, default: false
    end
  end
end
