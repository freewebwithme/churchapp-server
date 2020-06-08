defmodule ChurchApp.Repo.Migrations.AddKeysFieldToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :google_api_key, :string
      add :stripe_secret_key, :string
      add :stripe_publishable_key, :string
      add :onesignal_app_id, :string
      add :onesignal_api_key, :string
    end
  end
end
