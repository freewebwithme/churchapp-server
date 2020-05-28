defmodule ChurchApp.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table("news") do
      add :content, :text

      add :church_id, references("churches")

      timestamps()
    end
  end
end
