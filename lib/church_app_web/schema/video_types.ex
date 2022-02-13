defmodule ChurchAppWeb.Schema.VideoTypes do
  use Absinthe.Schema.Notation

  object :video_search_response do
    field(:id, :string)
    field(:etag, :string)
    field(:next_page_token, :string)
    field(:prev_page_token, :string)
    field(:results_per_page, :integer)
    field(:total_results, :integer)
    field(:items, list_of(:video_search_result))
  end

  object :video_search_result do
    field(:id, :string)
    field(:etag, :string)
    field(:video_id, :string)
    field(:channel_id, :string)
    field(:channel_title, :string)
    field(:description, :string)
    field(:live_broadcast_content, :string)
    field(:published_at, :string)
    field(:title, :string)
    field(:thumbnail_url, :string)
  end

  object :playlist do
    field :id, :id
    field :playlist_id, :string
    field :playlist_title, :string
    field :description, :string
    field :thumbnail_url, :string
  end
end
