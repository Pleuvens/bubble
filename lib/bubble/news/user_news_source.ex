defmodule Bubble.News.UserNewsSource do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Accounts.User
  alias Bubble.News.NewsSource

  schema "users_news_sources" do
    belongs_to :user, User, type: :binary_id
    belongs_to :news_source, NewsSource, type: :binary_id
    field :is_active, :boolean, default: true

    timestamps()
  end

  def changeset(user_news_source, attrs) do
    user_news_source
    |> cast(attrs, [:user_id, :news_source_id, :is_active])
    |> validate_required([:user_id, :news_source_id])
    |> unique_constraint([:user_id, :news_source_id])
  end
end
