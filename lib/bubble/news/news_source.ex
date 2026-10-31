defmodule Bubble.News.NewsSource do
  use Bubble.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Bubble.Accounts.User
  alias Bubble.News.News
  alias Bubble.News.UserNewsSource
  alias Utils.FeedUrl

  schema "news_sources" do
    field :name, :string
    field :url, :string
    field :description, :string
    field :last_fetched_at, :utc_datetime_usec
    field :content_type, Ecto.Enum, values: [:article, :video], default: :article
    field :is_featured, :boolean, default: false
    field :orphaned_at, :utc_datetime_usec

    has_many :news, News
    many_to_many :users, User, join_through: UserNewsSource

    timestamps()
  end

  def changeset(news_source, attrs) do
    news_source
    |> cast(attrs, [:name, :url, :description, :last_fetched_at, :content_type, :is_featured])
    |> validate_required([:name, :url, :content_type])
    |> FeedUrl.validate_fetchable(:url)
    |> unique_constraint(:url)
  end

  def due_for_fetch(query \\ __MODULE__) do
    from ns in query,
      where: is_nil(ns.last_fetched_at) or fragment("now() - ? > '23 hours'", ns.last_fetched_at)
  end
end
