defmodule ChurchAppWeb.Resolvers.Accounts do
  alias ChurchApp.Accounts
  alias ChurchApp.Emails.Postman

  def me(_, _, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def me(_, _, _), do: {:ok, nil}

  def update_me(_, args, _) do
    %{user_id: user_id} = args
    user = Accounts.get_user(user_id)
    Accounts.update_user(user, args)
  end

  def change_password(
        _,
        %{email: email, current_password: current_password, new_password: new_password},
        _
      ) do
    Accounts.change_password(email, current_password, new_password)
  end

  def reset_password(
        _,
        %{
          email_from_token: email_from_token,
          email_from_input: email_from_input,
          new_password: new_password
        },
        _
      ) do
    # compare 2 emails for security
    case email_from_token == email_from_input do
      true ->
        Accounts.reset_password(email_from_token, new_password)

      _ ->
        {:error, "이메일이 맞지 않습니다"}
    end
  end

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
        with {:ok, user} <- Accounts.create_user(args) do
          # Verify recaptcha value
          token = ChurchAppWeb.AuthToken.sign(user)
          {:ok, %{user: user, token: token}}
        end

      _ ->
        {:error, "가입할 수 없습니다.  다시 시도하세요"}
    end
  end

  @doc """
  Password reset start when user enter email address in password-reset page
  """

  def password_reset_start(_, %{email: email, recaptcha_value: recaptcha_value}, _) do
    # Check if email is valid user.
    case Recaptcha.verify(recaptcha_value) do
      {:ok, _response} ->
        Postman.send_reset_password_email(email)

      _ ->
        {:error, "더 이상 진행할 수 없습니다. 다시 시도하세요"}
    end
  end

  def verify_token_for_reset_password(_, %{token: token}, _) do
    # 10 min
    case ChurchAppWeb.AuthToken.verify(token, 600) do
      {:ok, %{id: id}} ->
        # get user's email
        # Why I pass email to client is that I want to save into client's prop
        # then want to compare with user's input(email) again with final submit to
        # reset password.

        user = Accounts.get_user(id)
        {:ok, %{success: true, email: user.email, message: "링크가 확인되었습니다"}}

      {:error, :invalid} ->
        {:error, "맞지않는 링크입니다."}

      {:error, :expired} ->
        {:error, "링크의 사용시간이 지났습니다.  다시 요청하세요."}

      _ ->
        {:error, "에러가 발생했습니다. 다시 시도하세요"}
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

  def app_request(_, args, _) do
    %{
      app_type: app_type,
      name: name,
      email: email,
      phone_number: phone_number,
      message: message,
      church_name: church_name
    } = args

    case Postman.send_app_request_email(app_type, name, email, phone_number, church_name, message) do
      %Bamboo.Email{} = _result ->
        {:ok, %{success: true, message: "앱 신청을 완료했습니다."}}

      _ ->
        {:error, %{success: false, message: "앱 신청을 진행할 수 없습니다.  다시 시도하세요"}}
    end
  end

  def contact_admin(_, args, _) do
    %{category: category, name: name, email: email, message: message} = args

    case Postman.contact_admin(category, name, email, message) do
      %Bamboo.Email{} = _result ->
        {:ok, %{success: true, message: "앱 신청을 완료했습니다."}}

      _ ->
        {:error, %{success: false, message: "앱 신청을 진행할 수 없습니다.  다시 시도하세요"}}
    end
  end

  def send_email(_, args, _) do
    %{name: name, email: email, message: message, recaptcha_value: value} = args

    case Recaptcha.verify(value) do
      {:ok, _response} ->
        case Postman.send_email(name, email, message) do
          %Bamboo.Email{} = _result ->
            {:ok, %{success: true, message: "앱 신청을 완료했습니다."}}

          _ ->
            {:error, %{success: false, message: "앱 신청을 진행할 수 없습니다.  다시 시도하세요"}}
        end

      _ ->
        {:error, %{success: false, message: "문제가 발생했습니다. 다시 시도하세요"}}
    end
  end
end
