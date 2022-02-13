defmodule ChurchApp.Repo.Migrations.AddHasKeyFieldToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :has_key, :boolean
    end
  end
end
