defmodule ChurchAppWeb.StripeWebhookController do
  @moduledoc """
  This module handle Stripe webhook event
  """
  use ChurchAppWeb, :controller
  alias ChurchApp.Accounts
  alias ChurchApp.Api.{OnesignalApi, StripeApi}

  def subscription_created(conn, params) do
    %{
      "data" => %{
        "object" => %{
          "customer" => stripe_id,
          "current_period_end" => current_period_end,
          "items" => %{
            "data" => [
              %{"subscription" => sub_id}
            ]
          }
        }
      }
    } = params

    # Convert unix time to utc time
    utc_current_period_end = Timex.from_unix(current_period_end)
    # Get related user using Stripe ID
    user = Accounts.get_user_by_stripe_id(stripe_id)

    # Save subscription id and current_period_end
    Accounts.update_user(user, %{
      subscribed: true,
      subscription_id: sub_id,
      current_period_end: utc_current_period_end
    })

    send_resp(conn, 200, "")
  end

  def subscription_deleted(conn, params) do
    %{"data" => %{"object" => %{"customer" => stripe_id}}} = params

    user = Accounts.get_user_by_stripe_id(stripe_id)
    Accounts.update_user(user, %{subscribed: false, subscription_id: nil})
    send_resp(conn, 200, "")
  end

  @doc """
  Handle invoice upcoming.
  1. Check installed app counts
  2. Change subscription(upgrading or downgrading)
  """
  def invoice_upcoming(conn, params) do
    IO.puts("Printing from invoice upcoming webhook")
    IO.inspect(params)

    # Get stripe customer id from webhook
    %{
      "data" => %{
        "object" => %{
          "customer" => stripe_id
        }
      }
    } = params

    user = Accounts.get_user_by_stripe_id(stripe_id)

    # Get subscription info
    {:ok, subscription} = StripeApi.get_subscription_info(user.subscription_id)
    # Get first subscription item
    [sub_item] = subscription.items.data |> Enum.take(1)

    # Get app user count using OneSignal app id
    case OnesignalApi.get_installed_count(user.church.onesignal_app_id) do
      {:ok, players} ->
        # Check numbers and change or stay subscription according to number
        cond do
          players < 50 ->
            # Small paln
            price_id = System.get_env("PRICE_FOR_SMALL")

            {:ok, subscription} =
              StripeApi.update_subscription(subscription.id, sub_item.id, price_id)

            # Update subscription_id and current_period_end
            update_sub_id_and_period_end(user, subscription)

          players < 100 ->
            price_id = System.get_env("PRICE_FOR_MEDIUM")

            {:ok, subscription} =
              StripeApi.update_subscription(subscription.id, sub_item.id, price_id)

            # Update subscription_id and current_period_end
            update_sub_id_and_period_end(user, subscription)

          players > 100 ->
            price_id = System.get_env("PRICE_FOR_LARGE")

            {:ok, subscription} =
              StripeApi.update_subscription(subscription.id, sub_item.id, price_id)

            # Update subscription_id and current_period_end
            update_sub_id_and_period_end(user, subscription)
        end

        send_resp(conn, 200, "")

      {:error, response} ->
        # Error occurred.
        IO.puts("Error occured whilte one signal api")
        IO.inspect(response)

        send_resp(conn, 500, response)
        # Do nothing. don't change subscription.
    end
  end

  defp update_sub_id_and_period_end(user, subscription) do
    IO.puts("Calling update sub_id and current_period_end")

    Accounts.update_user(user, %{
      subscription_id: subscription.id,
      current_period_end: subscription.current_period_end
    })
  end
end
