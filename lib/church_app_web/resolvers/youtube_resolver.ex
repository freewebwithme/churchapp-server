defmodule ChurchAppWeb.Resolvers.YoutubeResolver do
  alias ChurchApp.{Youtube, Videos, Accounts}
  alias ChurchApp.Response.{VideoSearchResponse, VideoSearchResult}
  alias ChurchApp.Utility

  @doc """
  """
  def search_videos(
        _,
        %{
          channel_id: channel_id,
          query: query,
          order: order,
          max_results: max_results,
          next_page_token: next_page_token_request
        },
        _
      ) do
    part = "snippet"

    # get church for api key
    church = Accounts.get_church_by_channel_id(channel_id)

    {:ok, video_search_list_response} =
      Youtube.search_videos(
        channel_id,
        part,
        query,
        order,
        max_results,
        next_page_token_request,
        church.google_api_key
      )

    %{
      etag: etag,
      nextPageToken: next_page_token,
      prevPageToken: prev_page_token,
      items: search_results,
      pageInfo: %{resultsPerPage: results_per_page, totalResults: total_results}
    } = video_search_list_response

    # Build VideoSearchResult Struct
    search_results_items =
      Enum.map(search_results, fn video ->
        {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: Utility.create_id(),
          etag: video.etag,
          video_id: video.id.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: video.snippet.liveBroadcastContent,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: Utility.get_thumbnail_url(video)
        }
      end)

    new_video_search_response = %VideoSearchResponse{
      id: Utility.create_id(),
      etag: etag,
      next_page_token: next_page_token,
      prev_page_token: prev_page_token,
      results_per_page: results_per_page,
      total_results: total_results,
      items: search_results_items
    }

    {:ok, new_video_search_response}
  end

  #  def get_most_recent_videos(_, %{count: count, church_id: church_id, channel_id: channel_id}, _) do
  #    videos = Videos.get_most_recent_videos(church_id, channel_id) |> Enum.take(count)
  #    {:ok, videos}
  #  end

  def get_all_playlists(_, %{channel_id: channel_id}, _) do
    playlists = Videos.get_all_playlists(channel_id)
    {:ok, playlists}
  end

  def get_playlist_items(
        _,
        %{church_id: church_id, next_page_token: next_page_token, playlist_id: playlist_id},
        _
      ) do
    # get church for api key
    church = Accounts.get_church_by_id(church_id)

    %{items: videos, next_page_token: token, page_info: _page_info} =
      Youtube.list_playlist_items(
        "snippet",
        playlist_id,
        25,
        next_page_token,
        church.google_api_key
      )

    playlist_items =
      Enum.map(videos, fn video ->
        {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: Utility.create_id(),
          etag: video.etag,
          video_id: video.snippet.resourceId.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: nil,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: Utility.get_thumbnail_url(video)
        }
      end)

    new_playlist_items_response = %VideoSearchResponse{
      id: Utility.create_id(),
      etag: nil,
      next_page_token: token,
      prev_page_token: nil,
      results_per_page: nil,
      total_results: nil,
      items: playlist_items
    }

    {:ok, new_playlist_items_response}
  end

  def refetch_latest_videos(_, %{church_id: church_id, user_id: user_id}, _) do
    # Check if user's church id and request church_id is matching
    IO.puts("Calling refetch latest videos")
    church = Accounts.get_church_by_id(church_id)
    IO.inspect(church.user_id)
    IO.inspect(user_id)

    case church.user_id == String.to_integer(user_id) do
      true ->
        IO.puts("Deleting videos......")
        # Matched! Refresh youtube videos
        Videos.delete_all_latest_videos(church.id)
        videos = Videos.get_most_recent_videos_from_youtube(church)
        {:ok, videos}

      _ ->
        {:error, "영상을 불러오는 중에 문제가 발생했습니다.  다시 시도하세요"}
    end
  end

  def search_live_streaming_videos(_, %{channel_id: channel_id}, _) do
    # get church for api key
    church = Accounts.get_church_by_channel_id(channel_id)

    {:ok, live_streaming} = Youtube.search_live_streraming(channel_id, church.google_api_key)

    %{
      etag: etag,
      nextPageToken: next_page_token,
      prevPageToken: prev_page_token,
      items: search_results,
      pageInfo: %{resultsPerPage: results_per_page, totalResults: total_results}
    } = live_streaming

    # Build VideoSearchResult Struct
    live_streaming_items =
      Enum.map(search_results, fn video ->
        {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)

        %VideoSearchResult{
          id: Utility.create_id(),
          etag: video.etag,
          video_id: video.id.videoId,
          channel_id: video.snippet.channelId,
          channel_title: video.snippet.channelTitle,
          description: video.snippet.description,
          live_broadcast_content: video.snippet.liveBroadcastContent,
          published_at: formatted_datetime,
          title: video.snippet.title,
          thumbnail_url: Utility.get_thumbnail_url(video)
        }
      end)

    live_streaming_search_response = %VideoSearchResponse{
      id: Utility.create_id(),
      etag: etag,
      next_page_token: next_page_token,
      prev_page_token: prev_page_token,
      results_per_page: results_per_page,
      total_results: total_results,
      items: live_streaming_items
    }

    {:ok, live_streaming_search_response}
  end
end
