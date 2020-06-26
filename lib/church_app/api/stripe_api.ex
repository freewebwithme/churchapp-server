defmodule ChurchApp.Api.StripeApi do
  alias Stripe.{Customer, PaymentIntent}
  alias ChurchApp.Accounts
  alias ChurchApp.Accounts.StripeUser

  def create_user(email, api_key) do
    Customer.create(%{email: email}, api_key: api_key)
  end

  def confirm_payment(amount, payment_method_id, email, church_id) do
    # Get church for api key
    church = Accounts.get_only_church_by_id(church_id)

    # Get or create stripe customer.
    stripe_user_id =
      case Accounts.get_stripe_user(email, church_id) do
        %StripeUser{} = user ->
          IO.puts("Stripe user found")
          user.stripe_id

        nil ->
          # User doesn't exist, then create a user account in stripe
          IO.puts("No stripe user exist, create it!")
          {:ok, stripe_user} = Accounts.create_stripe_user(email, church_id)
          stripe_user.stripe_id
      end

    # Attach payment method to customer
    {:ok, _result} =
      Stripe.PaymentMethod.attach(%{customer: stripe_user_id, payment_method: payment_method_id},
        api_key: church.stripe_secret_key
      )

    # Make a payment
    case PaymentIntent.create(
           %{
             amount: amount,
             currency: "USD",
             customer: stripe_user_id,
             payment_method: payment_method_id,
             receipt_email: email,
             off_session: false,
             confirm: true
           },
           api_key: church.stripe_secret_key
         ) do
      {:ok, result} ->
        [charge] = Enum.take(result.charges.data, 1)

        payment_result = %{
          id: result.id,
          amount_received: result.amount_received,
          receipt_url: charge.receipt_url,
          status: result.status
        }

        {:ok, payment_result}

      {:error, _result} ->
        message = "결제를 진행할 수 없습니다."
        {:error, message}
    end
  end
end
