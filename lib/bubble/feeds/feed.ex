defmodule Bubble.Feeds.Feed do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Feeds.FeedSource

  schema "feeds" do
    field :title, :string
    field :url, :string
    field :published_at, :utc_datetime
    field :content, :string
    field :description, :string

    belongs_to :feed_source, FeedSource

    timestamps()
  end

  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:title, :url, :published_at, :content, :description, :feed_source_id])
    |> validate_required([:title, :url, :published_at, :description])
    |> unique_constraint(:url)
  end
end
