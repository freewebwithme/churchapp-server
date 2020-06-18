defmodule ChurchApp.Emails.Email do
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

  defp base_email do
    new_email()
    |> from("churchapp.dev@gmail.com")
    |> put_header("Reply-to", "churchapp.dev@gmail.com")
  end
end
