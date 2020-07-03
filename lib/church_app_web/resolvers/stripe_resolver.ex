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

  @doc """
  Create customer portal session link using %Stripe.BillingPortal.Session
  So user(church) can manage their subscription
  """
  def create_stripe_redirect_url(_, %{stripe_id: stripe_id}, _) do
    case StripeApi.create_customer_portal_session(stripe_id) do
      {:ok, session} ->
        {:ok, %{url: session.url, message: "success!"}}

      {:error, response} ->
        IO.puts("Printing stripe customer portal error")
        IO.inspect(response)
        {:error, %{url: nil, message: "문제가 발생했습니다. 잠시후 다시 시도하세요"}}
    end
  end
end
