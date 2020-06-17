defmodule ChurchApp.Email do
  import Bamboo.Email
  import Bamboo.Phoenix

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
    |> html_body("
      <div>
        <h4>패스워드 복구 링크입니다. 클릭하세요</h4>
        <a href='<%= @link %>>패스워드 복구 링크 가기</a>
      </div>
    ")
  end

  defp base_email do
    new_email()
    |> from("churchapp.dev@gmail.com")
    |> put_header("Reply-to", "churchapp.dev@gmail.com")
  end
end
