defmodule ChurchApp.Accounts.Church do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChurchApp.Videos.LatestVideos
  alias ChurchApp.Accounts.{StripeUser, Employee, Schedule, News}

  schema "churches" do
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :phone_number, :string
    field :email, :string
    field :website, :string
    field :has_key, :boolean, default: false
    field :active, :boolean, default: false

    field :google_api_key, ChurchApp.Encrypted.Binary
    field :stripe_secret_key, ChurchApp.Encrypted.Binary
    field :stripe_publishable_key, ChurchApp.Encrypted.Binary
    field :onesignal_app_id, ChurchApp.Encrypted.Binary
    field :onesignal_api_key, ChurchApp.Encrypted.Binary

    embeds_many :schedules, Schedule, on_replace: :delete
    belongs_to :user, ChurchApp.Accounts.User
    has_many :latest_videos, LatestVideos
    has_many :stripe_users, StripeUser
    has_many :employees, Employee
    has_many :news, News

    timestamps()
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [
      :name,
      :intro,
      :uuid,
      :channel_id,
      :address_line_one,
      :address_line_two,
      :phone_number,
      :email,
      :website,
      :has_key,
      :active,
      :google_api_key,
      :stripe_secret_key,
      :stripe_publishable_key,
      :onesignal_app_id,
      :onesignal_api_key
    ])
    |> validate_required([:name, :intro, :uuid, :channel_id])
    |> unique_constraint(:channel_id)
  end
end
