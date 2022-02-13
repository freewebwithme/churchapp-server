defmodule ChurchApp.Repo.Migrations.ChangeKeysFieldToEncryptedInChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      remove :google_api_key, :string
      remove :stripe_secret_key, :string
      remove :stripe_publishable_key, :string
      remove :onesignal_app_id, :string
      remove :onesignal_api_key, :string

      add :google_api_key, :binary
      add :stripe_secret_key, :binary
      add :stripe_publishable_key, :binary
      add :onesignal_app_id, :binary
      add :onesignal_api_key, :binary
    end
  end
end
