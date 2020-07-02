defmodule ChurchApp.Api.OnesignalApi do
  alias OneSignal.Notification
  alias OneSignal.App

  def send_notification(title, message, api_key, app_id) do
    Notification.send(%{"en" => title}, %{"en" => message}, api_key, app_id, %{
      included_segments: ["All"]
    })
  end

  def get_installed_count(app_id) do
    case App.get_app_info(app_id) do
      {:ok, %{"players" => players}} ->
        {:ok, players}

      {:error, response} ->
        {:error, response}
    end
  end
end
