defmodule ChurchAppWeb.Resolvers.Accounts do
  alias ChurchApp.Accounts

  def me(_, _, %{context: %{current_user: user}}) do
    IO.puts("Found a user")
    IO.inspect(user)
    {:ok, user}
  end

  def me(_, _, _), do: {:ok, nil}

  def sign_in(_, %{email: email, password: password}, _) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = ChurchAppWeb.AuthToken.sign(user)
        {:ok, %{user: user, token: token}}

      :error ->
        {:error, "로그인 할 수 없습니다. 이메일과 패스워드를 확인하세요"}
    end
  end

  def sign_up(_, args, _) do
    # Before creating new user, check recaptcha value
    # to check if bot is not.
    %{recaptcha_value: value} = args

    case Recaptcha.verify(value) do
      {:ok, _response} ->
        IO.puts("Recaptcha is verified")

        with {:ok, user} <- Accounts.create_user(args) do
          # Verify recaptcha value
          token = ChurchAppWeb.AuthToken.sign(user)
          {:ok, %{user: user, token: token}}
        end

      _ ->
        IO.puts("Recaptcha is not verified")
        {:error, "가입할 수 없습니다.  다시 시도하세요"}
    end
  end

  def create_church(_, args, _) do
    Accounts.create_church(args)
  end

  def get_church(_, %{uuid: uuid}, _) do
    church = Accounts.get_church_by_uuid(uuid)
    {:ok, church}
  end

  def update_church(_, args, _) do
    %{church_id: church_id} = args
    church = Accounts.get_church_by_id(church_id)
    Accounts.update_church(church, args)
  end

  def update_service_info(_, %{church_id: church_id, schedules: schedules}, _) do
    Accounts.update_service_info(church_id, schedules)
  end

  def create_employee(_, arg, _) do
    Accounts.create_employee(arg)
  end

  def update_employee(_, arg, _) do
    Accounts.update_employee(arg)
  end

  def delete_employee(_, arg, _) do
    Accounts.delete_employee(arg)
  end

  def create_news(_, args, _) do
    Accounts.create_news(args)
  end

  def update_news(_, args, _) do
    Accounts.update_news(args)
  end

  def delete_news(_, args, _) do
    Accounts.delete_news(args)
  end

  def delete_slide_image(_, %{slider_number: slider_number, user_id: user_id}, _) do
    Accounts.delete_slide_image(user_id, slider_number)
  end
end
