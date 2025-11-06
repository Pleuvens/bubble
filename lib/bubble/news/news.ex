defmodule Bubble.News.News do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.News.NewsSource

  schema "news" do
    field :title, :string
    field :url, :string
    field :published_at, :utc_datetime
    field :content, :string
    field :description, :string

    belongs_to :news_source, NewsSource

    timestamps()
  end

  def changeset(news, attrs) do
    news
    |> cast(attrs, [:title, :url, :published_at, :content, :description, :news_source_id])
    |> validate_required([:title, :url, :published_at, :description])
    |> unique_constraint(:url)
  end
end
