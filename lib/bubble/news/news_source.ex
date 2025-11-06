defmodule Bubble.News.NewsSource do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Accounts.User
  alias Bubble.News.News
  alias Bubble.News.UserNewsSource

  schema "news_sources" do
    field :name, :string
    field :url, :string
    field :description, :string
    field :last_fetched_at, :utc_datetime_usec

    has_many :news, News
    many_to_many :users, User, join_through: UserNewsSource

    timestamps()
  end

  def changeset(news_source, attrs) do
    news_source
    |> cast(attrs, [:name, :url, :description, :last_fetched_at])
    |> validate_required([:name, :url])
    |> unique_constraint(:url)
  end
end
