defmodule ChurchApp.Youtube do
  @moduledoc """
  Call YouTube Api and build a ecto struct for each use case.
  """
  alias ChurchApp.Api.YoutubeApi
  alias GoogleApi.YouTube.V3.Connection

  def initialize_connection() do
    api_key = Application.get_env(:church_app, :api_key)
    connection = Connection.new()
    {api_key, connection}
  end

  def list_playlists_info(channel_id, part, max_results) do
    {api_key, connection} = initialize_connection()

    with {:ok, %{items: playlists, nextPageToken: next_page_token, pageInfo: page_info}} <-
           YoutubeApi.get_playlists(connection, part, api_key, channel_id, max_results) do
      %{items: playlists, next_page_token: next_page_token, page_info: page_info}
    else
      {:error, info} -> {:error, info}
    end
  end

  def list_playlist_items(part, playlist_id, max_results, next_page_token) do
    {api_key, connection} = initialize_connection()

    with {:ok, %{items: playlist_items, nextPageToken: next_page_token, pageInfo: page_info}} <-
           YoutubeApi.get_playlist_items(
             connection,
             part,
             api_key,
             playlist_id,
             max_results,
             next_page_token
           ) do
      %{items: playlist_items, next_page_token: next_page_token, page_info: page_info}
    else
      {:error, info} -> {:error, info}
    end
  end

  def search_videos(channel_id, part, query, order, max_results, next_page_token) do
    {api_key, connection} = initialize_connection()

    with {:ok, video_search_list_response} <-
           YoutubeApi.search_videos(
             connection,
             part,
             query,
             order,
             api_key,
             channel_id,
             max_results,
             next_page_token
           ) do
      # build results
      {:ok, video_search_list_response}
    else
      {:error, info} -> {:error, info}
    end
  end

  def search_live_streraming(channel_id) do
    {api_key, connection} = initialize_connection()

    with {:ok, live_streaming} <-
           YoutubeApi.search_live_streaming(connection, api_key, channel_id) do
      {:ok, live_streaming}
    else
      {:error, info} -> {:error, info}
    end
  end
end
