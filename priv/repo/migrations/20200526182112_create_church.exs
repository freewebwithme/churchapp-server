defmodule ChurchApp.Repo.Migrations.CreateChurch do
  use Ecto.Migration

  def change do
    create table("churches") do
      add :name, :string
      add :uuid, :string
      add :intro, :text
      add :channel_id, :citext, null: false
      add :phone_number, :string
      add :email, :string
      add :address_line_one, :string
      add :address_line_two, :string
      add :user_id, references("users")
      add :schedules, :map

      timestamps()
    end

    create unique_index(:churches, [:channel_id])
  end
end
