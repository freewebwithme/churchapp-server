defmodule ChurchApp.Emails.Postman do
  alias ChurchApp.Accounts
  alias ChurchApp.Accounts.User
  alias ChurchApp.Emails.{Email, Mailer}
  alias ChurchApp.Response.PasswordResetResponse

  def send_reset_password_email(email) do
    case Accounts.get_user_by_email(email) do
      %User{} = user ->
        # build token
        token = ChurchAppWeb.AuthToken.sign(user)
        # build link
        link = "http://localhost:3000/reset-password/" <> token
        # send email
        # Email.sending_email(email)
        Email.password_reset_email(email, link) |> Mailer.deliver_later()
        IO.puts("Printing link")
        IO.inspect(link)
        {:ok, %PasswordResetResponse{recipient: email, message: "패스워드 리셋 링크를 보냈습니다. 이메일을 확인하세요."}}

      _ ->
        {:error, "잘못된 이메일 주소 입니다."}
    end
  end

  def send_app_request_email(app_type, name, email, phone_number, church_name, message) do
    Email.app_request_email(app_type, name, email, phone_number, church_name, message)
    |> Mailer.deliver_later()
  end

  def contact_admin(category, name, email, message) do
    Email.contact_admin(category, name, email, message)
    |> Mailer.deliver_later()
  end
end
