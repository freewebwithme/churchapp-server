defmodule ChurchApp.Repo.Migrations.AddWebsiteFieldToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :website, :string
    end
  end
end
