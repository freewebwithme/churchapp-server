defmodule ChurchApp.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: ChurchAppWeb.EmailView

  def welcome_email(email) do
    base_email()
    |> to(email)
    |> subject("ChurchApp에 가입하신걸 환영합니다")
  end

  def password_reset_email(email, link) do
    base_email()
    |> to(email)
    |> subject("ChurchApp 패스워드 복구 링크입니다")
    |> assign(:link, link)
    # use password_reset.html.eex
    |> render(:password_reset)

    # |> put_html_layout({ChurchAppWeb.LayoutView, "password_reset.html"})
  end

  # Email to admin
  def app_request_email(app_type, name, email, phone_number, church_name, message) do
    new_email()
    |> to("churchapp.dev@gmail.com")
    |> from(email)
    |> subject("App request from ChurchApp.dev")
    |> assign(:app_type, app_type)
    |> assign(:name, name)
    |> assign(:email, email)
    |> assign(:phone_number, phone_number)
    |> assign(:church_name, church_name)
    |> assign(:message, message)
    |> render(:app_request)
  end

  def contact_admin(category, name, email, message) do
    new_email()
    |> to("churchapp.dev@gmail.com")
    |> from(email)
    |> subject("Contact from registered user")
    |> assign(:category, category)
    |> assign(:name, name)
    |> assign(:email, email)
    |> assign(:message, message)
    |> render(:contact_admin)
  end

  def send_email(name, email, message) do
    new_email()
    |> to("churchapp.dev@gmail.com")
    |> from(email)
    |> subject("Message from Landing page")
    |> assign(:name, name)
    |> assign(:email, email)
    |> assign(:message, message)
    |> render(:send_email)
  end

  defp base_email do
    new_email()
    |> from("churchapp.dev@gmail.com")
    |> put_header("Reply-to", "churchapp.dev@gmail.com")
  end
end
