defmodule ChurchApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ChurchApp.Repo

  alias ChurchApp.Accounts.Church
  alias ChurchApp.Accounts.{User, StripeUser, Employee}
  alias ChurchApp.Utility
  alias ChurchApp.Videos

  alias ChurchApp.Api.StripeApi

  def get_church_by_id(church_id) do
    church = Repo.get_by(Church, id: church_id) |> Repo.preload(:latest_videos)

    return_church_with_latest_videos(church)
  end

  def get_church_by_uuid(uuid) do
    # |> Repo.preload([:latest_videos])
    church = Repo.get_by(Church, uuid: uuid) |> Repo.preload(:latest_videos)
    church
    # return_church_with_latest_videos(church)
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
          latest_videos = Videos.get_most_recent_videos(church)
          Map.put(church, :latest_videos, latest_videos)

        _ ->
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

    case changeset.changes["channel_id"] do
      nil ->
        # channel id is updated, call latest videos from youtube
        {:ok, church} = Repo.update(changeset)
        # delete old latest videos
        Videos.delete_all_latest_videos(church.id)
        latest_videos = Videos.get_most_recent_videos_from_youtube(church)
        church = Map.put(church, :latest_videos, latest_videos)
        {:ok, church}

      _ ->
        Repo.update(changeset)
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

  def create_employee(attrs) do
    %{profile_image: profile_image} = attrs
    # Add default profile image
    attrs =
      with true <- is_nil(profile_image),
           0 <- String.length(profile_image) do
        Map.put(
          attrs,
          :profile_image,
          "https://churchapp-la.s3-us-west-1.amazonaws.com/default-avatar.jpg"
        )
      else
        _ ->
          attrs
      end

    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
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
      Repo.delete(employee)
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

  def delete_slide_image(user_id, slider_number) do
    user = get_user(user_id)
    bucket_name = Utility.get_bucket_name()

    cond do
      slider_number == "sliderTwo" ->
        image_key_name = user.church.slide_image_two

        case is_nil(image_key_name) do
          false ->
            result = Utility.delete_file_from_s3(bucket_name, image_key_name)
            update_church(user.church, %{slide_image_two: nil})

          _ ->
            nil
        end

      slider_number == "sliderThree" ->
        image_key_name = user.church.slide_image_two

        case is_nil(image_key_name) do
          false ->
            Utility.delete_file_from_s3(bucket_name, image_key_name)
            update_church(user.church, %{slide_image_three: nil})

          _ ->
            nil
        end
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get(User, id) |> Repo.preload(:church)
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
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
    {:ok, stripe_user} = StripeApi.create_user(email)

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
