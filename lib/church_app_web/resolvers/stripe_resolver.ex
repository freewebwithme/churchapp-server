defmodule ChurchAppWeb.Resolvers.StripeResolver do
  alias ChurchApp.Api.StripeApi

  def make_offering(
        _,
        %{
          payment_method_id: payment_method_id,
          email: email,
          amount: amount,
          church_id: church_id
        },
        _
      ) do
    # Stripe uses amount in cents so convert it
    {amount, ""} = Integer.parse(amount)
    amount = amount * 100

    case StripeApi.confirm_payment(amount, payment_method_id, email, church_id) do
      {:ok, payment_result} ->
        {:ok, payment_result}

      {:error, message} ->
        {:error, message}
    end
  end
end
