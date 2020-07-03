defmodule ChurchApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ChurchApp.Repo

  alias ChurchApp.Accounts.Church
  alias ChurchApp.Accounts.{User, StripeUser, Employee, News}
  alias ChurchApp.{Utility, Videos}

  alias ChurchApp.Api.StripeApi

  def list_users() do
    Repo.all(User) |> Repo.preload(:church)
  end

  def get_only_church_by_id(church_id) do
    Repo.get_by(Church, id: church_id)
  end

  def get_church_by_id(church_id) do
    church = Repo.get_by(Church, id: church_id) |> Repo.preload(:latest_videos)

    case church.has_key do
      true ->
        return_church_with_latest_videos(church)

      _ ->
        church
    end
  end

  def get_church_by_uuid(uuid) do
    church = Repo.get_by(Church, uuid: uuid) |> Repo.preload(:latest_videos)
    church
  end

  @doc """
  This function used for only get church
  Used in YoutubeController.handle_upload_notification()
  """
  def get_church_by_channel_id(channel_id) do
    Repo.get_by(Church, channel_id: channel_id)
  end

  @doc """
  Check if church has latest videos.
  if no latest videos, call youtube api to get latest videos.
  """
  def return_church_with_latest_videos(church) do
    church =
      case Enum.empty?(church.latest_videos) do
        true ->
          IO.puts("Fetching recent videos")
          latest_videos = Videos.get_most_recent_videos(church)
          Map.put(church, :latest_videos, latest_videos)

        _ ->
          IO.puts("Church has latest videos already")
          church
      end

    church
  end

  def create_church(attrs) do
    %{user_id: id} = attrs
    user = Repo.get_by(User, id: id)
    attrs = Map.put(attrs, :uuid, UUID.uuid1())

    %Church{}
    |> Church.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_church(%Church{} = church, attrs) do
    changeset = Church.changeset(church, attrs)

    case Map.has_key?(changeset.changes, :channel_id) do
      false ->
        IO.puts("No channel id changed")
        Repo.update(changeset)

      _ ->
        case church.has_key do
          # Church has api key, so it is safe to call youtube api
          true ->
            IO.puts("Channel id has changed call latest video")
            # channel id is updated, call latest videos from youtube
            {:ok, church} = Repo.update(changeset)
            # delete old latest videos
            Videos.delete_all_latest_videos(church.id)
            latest_videos = Videos.get_most_recent_videos_from_youtube(church)
            church = Map.put(church, :latest_videos, latest_videos)
            {:ok, church}

          _ ->
            # CHurch has no api key set up.
            # Don't call Youtube Api
            Repo.update(changeset)
        end
    end
  end

  def update_service_info(church_id, schedules) do
    church = get_church_by_id(church_id)
    church_changeset = Ecto.Changeset.change(church)

    {:ok, schedule_map} = Jason.decode(schedules)

    # Build Schedule struct
    final_schedules =
      Enum.map(schedule_map, fn {k, v} ->
        %ChurchApp.Accounts.Schedule{
          service_name: k,
          service_time: List.first(v),
          order: List.last(v)
        }
      end)

    church_changeset = Ecto.Changeset.put_embed(church_changeset, :schedules, final_schedules)
    Repo.update(church_changeset)
  end

  def get_employee_by_id(church_id, employee_id) do
    query = from e in Employee, where: e.church_id == ^church_id and e.id == ^employee_id
    Repo.one(query)
  end

  def create_employee(attrs) do
    %{profile_image: profile_image} = attrs
    # Add default profile image
    attrs =
      with true <- is_nil(profile_image) do
        Map.put(
          attrs,
          :profile_image,
          "default-avatar.jpg"
        )
      else
        _ ->
          attrs
      end

    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  def update_employee_profile_image(employee, profile_image) do
    employee
    |> Employee.changeset(%{profile_image: profile_image})
    |> Repo.update()
  end

  def update_employee(attrs) do
    %{id: employee_id, church_id: church_id} = attrs
    employee = Repo.get_by(Employee, id: employee_id)
    {church_id, ""} = Integer.parse(church_id)

    IO.puts("Comparing church id")
    IO.inspect(employee.church_id)
    IO.inspect(church_id)

    with true <- employee.church_id == church_id do
      employee
      |> Employee.changeset(attrs)
      |> Repo.update()
    else
      false ->
        {:error, "정보를 수정할 수가 없습니다."}
    end
  end

  def delete_employee(attrs) do
    %{id: employee_id, church_id: church_id} = attrs
    employee = Repo.get_by(Employee, id: employee_id)
    {church_id, ""} = Integer.parse(church_id)

    with true <- employee.church_id == church_id do
      case employee.profile_image == "default-avatar.jpg" do
        true ->
          # Employee is using default avatar image.
          # Don't delete from amazon S3
          Repo.delete(employee)

        _ ->
          # Delete Profile image from amazon s3
          bucket_name = Utility.get_bucket_name()
          Utility.delete_file_from_s3(bucket_name, employee.profile_image)
          Repo.delete(employee)
      end
    else
      false ->
        {:error, "정보를 수정할 수가 없습니다."}
    end
  end

  def delete_church(%Church{} = church) do
    Repo.delete(church)
  end

  def change_church(%Church{} = church) do
    Church.changeset(church, %{})
  end

  def create_news(attrs) do
    %News{}
    |> News.changeset(attrs)
    |> Repo.insert()
  end

  def update_news(attrs) do
    %{church_id: church_id, id: news_id, content: _content} = attrs
    news = Repo.get_by(News, id: news_id)
    {church_id, ""} = Integer.parse(church_id)

    with true <- news.church_id == church_id do
      news
      |> News.changeset(attrs)
      |> Repo.update()
    else
      false ->
        {:error, "정보를 수정할 수가 없습니다."}
    end
  end

  def delete_news(attrs) do
    %{church_id: church_id, id: news_id} = attrs
    news = Repo.get_by(News, id: news_id)
    {church_id, ""} = Integer.parse(church_id)

    with true <- news.church_id == church_id do
      Repo.delete(news)
    else
      false ->
        {:error, "정보를 수정할 수가 없습니다."}
    end
  end

  def create_user(attrs \\ %{}) do
    # When user signs up, create stripe id too
    # Get master api key
    master_api_key = System.get_env("MASTER_STRIPE_API_KEY")
    %{email: email} = attrs
    {:ok, customer} = StripeApi.create_user(email, master_api_key)

    # Add stripe user id to attrs
    attrs = Map.put(attrs, :stripe_id, customer.id)

    %User{}
    |> User.changeset(attrs)
    # I need to set church to nil or not,
    # It will raise :church is not loaded error on sign up
    |> Ecto.Changeset.put_assoc(:church, nil)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get(User, id) |> Repo.preload(:church)
  end

  def get_user_by_email(email) do
    # This is used by password reset function
    # Don't need to preload church.
    Repo.get_by(User, email: email)
  end

  def get_user_by_stripe_id(stripe_id) do
    Repo.get_by(User, stripe_id: stripe_id)
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def change_password(email, current_password, new_password) do
    # Authenticate user with email and password
    case authenticate_user(email, current_password) do
      {:ok, user} ->
        update_user(user, %{password: new_password})

      _ ->
        {:error, "이메일과 패스워드가 일치하지 않습니다"}
    end
  end

  def reset_password(email, new_password) do
    # get user by email
    user = get_user_by_email(email)
    update_user(user, %{password: new_password})
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email) |> Repo.preload(:church)

    with %{password: hashed_password} when not is_nil(hashed_password) <- user,
         true <- Comeonin.Ecto.Password.valid?(password, hashed_password) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def create_stripe_user(email, church_id) do
    # Get church stripe api key
    church = get_only_church_by_id(church_id)

    # Pass church's stripe key for Stripe request
    {:ok, stripe_user} = StripeApi.create_user(email, church.stripe_secret_key)

    %StripeUser{}
    |> StripeUser.changeset(%{email: email, stripe_id: stripe_user.id, church_id: church_id})
    |> Repo.insert()
  end

  def get_stripe_user(email, church_id) do
    Repo.get_by(StripeUser, email: email, church_id: church_id)
  end

  def data() do
    Dataloader.Ecto.new(ChurchApp.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
