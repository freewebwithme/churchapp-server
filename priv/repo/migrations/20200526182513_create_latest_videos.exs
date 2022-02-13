defmodule ChurchApp.Repo.Migrations.CreateLatestVideos do
  use Ecto.Migration

  def change do
    create table("latest_videos") do
      add :title, :string
      add :description, :text
      add :video_id, :string
      add :thumbnail_url, :string
      add :published_at, :string
      add :channel_title, :string
      add :church_id, references("churches")

      timestamps()
    end
  end
end
