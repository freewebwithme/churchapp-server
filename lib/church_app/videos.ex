defmodule ChurchApp.Videos do
  @moduledoc """
  Module for video.
  Creating videos and insert, get videos
  """
  import Ecto.Query, warn: false
  alias ChurchApp.Repo
  alias ChurchApp.Videos.LatestVideos
  alias ChurchApp.Youtube
  alias ChurchApp.Response.Playlist
  alias ChurchApp.Utility
  alias ChurchApp.Accounts

  alias UUID

  def list_latest_videos(church_id) do
    church = Accounts.get_church_by_id(church_id)
    church.latest_videos
  end

  @doc """
  Insert all 25 videos at once using insert_all
  """
  def insert_all_latest_videos(videos) do
    Repo.insert_all(LatestVideos, videos, on_conflict: :nothing, returning: true)
  end

  def delete_all_latest_videos(church_id) do
    query = from v in LatestVideos, where: v.church_id == ^church_id
    Repo.delete_all(query)
  end

  @doc """
  buid list of maps for insert_all_latest_videos
  """
  def build_videos_from_response(response, church_id) do
    church_id =
      case is_binary(church_id) do
        true ->
          String.to_integer(church_id)

        _ ->
          church_id
      end

    %{
      etag: _etag,
      nextPageToken: _next_page_token,
      prevPageToken: _prev_page_token,
      items: search_results,
      pageInfo: _page_info
    } = response

    Enum.map(search_results, fn video ->
      {:ok, formatted_datetime} = Utility.format_datetime(video.snippet.publishedAt)
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      %{
        title: video.snippet.title,
        description: video.snippet.description,
        channel_title: video.snippet.channelTitle,
        video_id: video.id.videoId,
        thumbnail_url: Utility.get_thumbnail_url(video),
        published_at: formatted_datetime,
        inserted_at: timestamp,
        updated_at: timestamp,
        church_id: church_id
      }
    end)
  end

  @doc """
  Check for most recent videos from database.
  If it is empty(maybe app loading for the first time?),
  Request Search List api to Youtube Data Api
  And save the result.
  If has videos, return them
  """
  def get_most_recent_videos(church) do
    with false <- Ecto.assoc_loaded?(church.latest_videos) do
      # LatestVideos is not loaded with church
      # So get a church with latest videos
      church =
        Repo.get_by(ChurchApp.Accounts.Church, id: church.id) |> Repo.preload(:latest_videos)

      case Enum.empty?(church.latest_videos) do
        true ->
          get_most_recent_videos_from_youtube(church)

        _ ->
          church.latest_videos
      end

      # There is no latest videos in database
      # Call API and save them to database
    else
      _ ->
        case Enum.empty?(church.latest_videos) do
          true ->
            get_most_recent_videos_from_youtube(church)

          _ ->
            church.latest_videos
        end
    end
  end

  def get_most_recent_videos_from_youtube(church) do
    {:ok, response} =
      Youtube.search_videos(
        church.channel_id,
        "snippet",
        "",
        "date",
        25,
        "",
        church.google_api_key
      )

    {_rows, videos} =
      build_videos_from_response(response, church.id)
      |> insert_all_latest_videos

    videos
  end

  def build_playlists(playlists) do
    Enum.map(playlists, fn playlist ->
      %Playlist{
        id: Utility.create_id(),
        playlist_title: playlist.snippet.title,
        description: playlist.snippet.description,
        thumbnail_url: Utility.get_thumbnail_url(playlist),
        playlist_id: playlist.id,
        published_at: playlist.snippet.publishedAt
      }
    end)
  end

  def get_all_playlists(channel_id) do
    # get church for api key
    church = Accounts.get_church_by_channel_id(channel_id)

    %{items: playlists, next_page_token: _token, page_info: _info} =
      Youtube.list_playlists_info(channel_id, "snippet", 25, church.google_api_key)

    build_playlists(playlists)
  end
end
