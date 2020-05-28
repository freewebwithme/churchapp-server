defmodule ChurchApp.Accounts.News do
  use Ecto.Schema
  import Ecto.Changeset

  schema "news" do
    field :content, :string

    belongs_to :church, ChurchApp.Accounts.Church

    timestamps()
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:content, :church_id])
    |> validate_required([:content])
  end
end
