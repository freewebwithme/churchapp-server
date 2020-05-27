defmodule ChurchApp.Api.YoutubeApi do
  alias GoogleApi.YouTube.V3.Api.{Playlists, PlaylistItems, Search}

  @doc """
  Get all Playlists in specified channel

  Returns a {:ok, %GoogleApi.YouTube.V3.Model.PlaylistListResponse{}}
  """

  def get_playlists(
        %Tesla.Client{} = connection,
        part \\ "snippet",
        api_key,
        channel_id,
        max_results \\ 10
      ) do
    Playlists.youtube_playlists_list(connection, part,
      key: api_key,
      channelId: channel_id,
      maxResults: max_results
    )
  end

  @doc """
  Get playlist items in specified playlist.
  Returns a {:ok, %GoogleApi.YouTube.V3.Model.PlaylistItemListResponse{}}
  """

  def get_playlist_items(
        connection,
        part \\ "snippet",
        api_key,
        playlist_id,
        max_results \\ 25,
        next_page_token \\ ""
      ) do
    PlaylistItems.youtube_playlist_items_list(connection, part,
      key: api_key,
      playlistId: playlist_id,
      maxResults: max_results,
      pageToken: next_page_token
    )
  end

  def search_videos(
        connection,
        part \\ "snippet",
        query \\ "",
        order \\ "date",
        api_key,
        channel_id,
        max_results \\ 25,
        next_page_token
      ) do
    Search.youtube_search_list(connection, part,
      key: api_key,
      channelId: channel_id,
      type: "video",
      maxResults: max_results,
      order: order,
      q: query,
      pageToken: next_page_token
    )
  end

  def search_live_streaming(connection, api_key, channel_id) do
    Search.youtube_search_list(connection, "snippet",
      key: api_key,
      channelId: channel_id,
      type: "video",
      maxResults: 1,
      order: "date",
      q: "",
      eventType: "live"
    )
  end
end
