defmodule Bubble.Feeds.Feed do
  use Bubble.Schema

  import Ecto.Changeset

  schema "feeds" do
    field :title, :string
    field :url, :string
    field :published_at, :utc_datetime_usec
    field :content, :string
    field :description, :string

    timestamps()
  end

  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:title, :url, :published_at, :content, :description])
    |> validate_required([:title, :url, :published_at, :description])
    |> unique_constraint(:url)
  end
end
