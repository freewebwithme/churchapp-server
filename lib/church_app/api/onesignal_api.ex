defmodule ChurchApp.Api.OnesignalApi do
  alias OneSignal.Notification

  def send_notification(title, message, api_key, app_id) do
    Notification.send(%{"en" => title}, %{"en" => message}, api_key, app_id, %{
      included_segments: ["All"]
    })
  end
end
