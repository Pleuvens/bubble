defmodule Bubble.Feeds.FeedSource do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Accounts.User
  alias Bubble.Feeds.Feed
  alias Bubble.Feeds.UserFeedSource

  schema "feed_sources" do
    field :name, :string
    field :url, :string
    field :description, :string
    field :is_active, :boolean, default: true
    field :last_fetched_at, :utc_datetime_usec

    has_many :feeds, Feed
    many_to_many :users, User, join_through: UserFeedSource

    timestamps()
  end

  def changeset(feed_source, attrs) do
    feed_source
    |> cast(attrs, [:name, :url, :description, :is_active, :last_fetched_at])
    |> validate_required([:name, :url])
    |> unique_constraint(:url)
  end
end
