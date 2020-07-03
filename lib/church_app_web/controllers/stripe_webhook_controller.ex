defmodule ChurchAppWeb.StripeWebhookController do
  @moduledoc """
  This module handle Stripe webhook event
  """
  use ChurchAppWeb, :controller
  alias ChurchApp.Accounts

  def subscription_created(conn, params) do
    %{"data" => %{"object" => %{"customer" => stripe_id}}} = params
    user = Accounts.get_user_by_stripe_id(stripe_id)
    Accounts.update_user(user, %{subscribed: true})
    send_resp(conn, 200, "")
  end

  def subscription_deleted(conn, params) do
    %{"data" => %{"object" => %{"customer" => stripe_id}}} = params
    user = Accounts.get_user_by_stripe_id(stripe_id)
    Accounts.update_user(user, %{subscribed: false})
    send_resp(conn, 200, "")
  end
end
