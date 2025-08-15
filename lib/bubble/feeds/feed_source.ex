defmodule Bubble.Feeds.FeedSource do
  use Bubble.Schema

  import Ecto.Changeset

  schema "feed_sources" do
    field :name, :string
    field :url, :string
    field :last_fetched_at, :utc_datetime_usec

    timestamps()
  end

  def changeset(feed_source, attrs) do
    feed_source
    |> cast(attrs, [:name, :url, :last_fetched_at])
    |> validate_required([:name, :url])
    |> unique_constraint(:url)
  end
end
