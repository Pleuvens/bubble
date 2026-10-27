defmodule Bubble.News.UserNewsSource do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Accounts.User
  alias Bubble.News.NewsSource
  alias Utils.FeedUrl

  schema "users_news_sources" do
    belongs_to :user, User, type: :binary_id
    belongs_to :news_source, NewsSource, type: :binary_id
    field :is_active, :boolean, default: true
    field :custom_url, :string
    field :custom_name, :string
    field :custom_description, :string

    timestamps()
  end

  def changeset(user_news_source, attrs) do
    user_news_source
    |> cast(attrs, [
      :user_id,
      :news_source_id,
      :is_active,
      :custom_url,
      :custom_name,
      :custom_description
    ])
    |> validate_required([:user_id, :news_source_id])
    |> validate_custom_url()
    |> validate_length(:custom_name, max: 255)
    |> unique_constraint([:user_id, :news_source_id])
  end

  defp validate_custom_url(changeset) do
    case get_field(changeset, :custom_url) do
      blank when blank in [nil, ""] -> changeset
      _url -> FeedUrl.validate_fetchable(changeset, :custom_url)
    end
  end
end
