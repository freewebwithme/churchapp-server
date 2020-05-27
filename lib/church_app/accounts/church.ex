defmodule ChurchApp.Accounts.Church do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChurchApp.Videos.LatestVideos
  alias ChurchApp.Accounts.{StripeUser, Employee, Schedule}

  schema "churches" do
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :phone_number, :string
    field :email, :string

    embeds_many :schedules, Schedule, on_replace: :delete
    belongs_to :user, ChurchApp.Accounts.User
    has_many :latest_videos, LatestVideos
    has_many :stripe_users, StripeUser
    has_many :employees, Employee

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
      :email
    ])
    |> validate_required([:name, :intro, :uuid, :channel_id])
    |> unique_constraint(:channel_id)
  end
end
