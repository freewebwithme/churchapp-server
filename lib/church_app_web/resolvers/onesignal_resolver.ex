defmodule ChurchAppWeb.Resolvers.OnesignalResolver do
  alias ChurchApp.Api.OnesignalApi
  alias ChurchApp.Accounts
  alias ChurchApp.Response.NotificationResponse

  def send_push(_, %{church_id: church_id, title: title, message: message}, _) do
    # get church to get api key and app id
    church = Accounts.get_church_by_id(church_id)

    response =
      OnesignalApi.send_notification(
        title,
        message,
        church.onesignal_api_key,
        church.onesignal_app_id
      )

    {:ok, %NotificationResponse{id: response.id, recipients: response.recipients}}
  end
end
