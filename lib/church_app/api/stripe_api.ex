defmodule ChurchApp.Api.StripeApi do
  alias Stripe.{Customer, PaymentIntent}
  alias ChurchApp.Accounts
  alias ChurchApp.Accounts.StripeUser

  def create_user(email) do
    Customer.create(%{email: email})
  end

  def confirm_payment(amount, payment_method_id, email, church_id) do
    # Get or create stripe customer.
    stripe_user_id =
      case Accounts.get_stripe_user(email, church_id) do
        %StripeUser{} = user ->
          user.stripe_id

        nil ->
          # User doesn't exist, then create a user account in stripe
          {:ok, stripe_user} = Accounts.create_stripe_user(email, church_id)
          stripe_user.stripe_id
      end

    # Attach payment method to customer
    {:ok, _result} =
      Stripe.PaymentMethod.attach(%{customer: stripe_user_id, payment_method: payment_method_id})

    # Make a payment
    case PaymentIntent.create(%{
           amount: amount,
           currency: "USD",
           customer: stripe_user_id,
           payment_method: payment_method_id,
           receipt_email: email,
           off_session: false,
           confirm: true
         }) do
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
