defmodule ChurchApp.Videos.LatestVideos do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChurchApp.Videos.LatestVideos

  schema "latest_videos" do
    field :title, :string
    field :description, :string
    field :video_id, :string
    field :thumbnail_url, :string
    field :published_at, :string
    field :channel_title, :string

    belongs_to :church, ChurchApp.Accounts.Church
    timestamps()
  end

  @doc false
  def changeset(%LatestVideos{} = latest_videos, attrs) do
    latest_videos
    |> cast(attrs, [
      :title,
      :description,
      :video_id,
      :thumbnail_url,
      :published_at,
      :channel_title
    ])
    |> validate_required([
      :title,
      :description,
      :video_id,
      :thumbnail_url,
      :published_at,
      :channel_title
    ])
  end
end
