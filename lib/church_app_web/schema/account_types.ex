defmodule ChurchAppWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation
  alias ChurchApp.{Accounts, Utility}

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
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
    field :schedules, list_of(:schedule)

    field :user, :user

    field :latest_videos, list_of(:latest_videos)
    field :employees, list_of(:employee), resolve: dataloader(Accounts)
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
