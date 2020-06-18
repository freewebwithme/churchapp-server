defmodule ChurchAppWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation
  alias ChurchApp.{Accounts, Utility}

  import Absinthe.Resolution.Helpers, only: [on_load: 2, dataloader: 1]

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone_number, :string
    field :admin, :boolean
    field :church, :church
  end

  object :church do
    field :id, :id
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string

    field :address_line_one, :string
    field :address_line_two, :string
    field :phone_number, :string
    field :email, :string
    field :website, :string
    field :has_key, :boolean

    # Key info, only for admin.
    field :google_api_key, :string
    field :stripe_secret_key, :string
    field :stripe_publishable_key, :string
    field :onesignal_app_id, :string
    field :onesignal_api_key, :string

    field :schedules, list_of(:schedule) do
      resolve(fn parent, _, _ ->
        schedules = Map.get(parent, :schedules)

        case is_nil(schedules) do
          true ->
            {:ok, schedules}

          _ ->
            {:ok, Enum.sort_by(schedules, & &1.order)}
        end
      end)
    end

    field :user, :user

    field :latest_videos, list_of(:latest_videos) do
      resolve(fn parent, _, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(Accounts, :latest_videos, parent)
        |> on_load(fn loader ->
          latest_videos = Dataloader.get(loader, Accounts, :latest_videos, parent)
          {:ok, Enum.sort_by(latest_videos, & &1.id, :asc)}
        end)
      end)
    end

    field :employees, list_of(:employee) do
      resolve(fn parent, _, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(Accounts, :employees, parent)
        |> on_load(fn loader ->
          employees = Dataloader.get(loader, Accounts, :employees, parent)
          {:ok, Enum.sort_by(employees, & &1.order)}
        end)
      end)
    end

    field :news, list_of(:news) do
      # Manually call on_load instead of dataloader function
      # Because I need to order by date desc
      resolve(fn parent, _args, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(Accounts, :news, parent)
        |> on_load(fn loader ->
          news = Dataloader.get(loader, Accounts, :news, parent)
          {:ok, Enum.sort_by(news, & &1.inserted_at, :desc)}
        end)
      end)
    end
  end

  object :schedule do
    field :service_name, :string
    field :service_time, :string
    field :order, :integer
  end

  object :employee do
    field :id, :id
    field :name, :string
    field :position, :string

    field :profile_image, :string do
      resolve(fn parent, _, _ ->
        # S3 key name (not a full url)
        profile_image = Map.get(parent, :profile_image)
        {:ok, Utility.build_image_url(profile_image)}
      end)
    end

    field :order, :integer
    field :church_id, :string
  end

  object :news do
    field :id, :id
    field :content, :string
    field :church_id, :string

    field :created_at, :string do
      resolve(fn parent, _, _ ->
        inserted_at = Map.get(parent, :inserted_at)
        {:ok, formatted_date} = Utility.format_datetime(inserted_at)
        {:ok, formatted_date}
      end)
    end
  end

  object :latest_videos do
    field :id, :id
    field :title, :string
    field :description, :string
    field :video_id, :string
    field :thumbnail_url, :string
    field :published_at, :string
    field :channel_title, :string
  end
end
