defmodule Bubble.Feeds.UserFeedSource do
  use Bubble.Schema

  import Ecto.Changeset

  alias Bubble.Accounts.User
  alias Bubble.Feeds.FeedSource

  schema "users_feed_sources" do
    belongs_to :user, User, type: :binary_id
    belongs_to :feed_source, FeedSource, type: :binary_id

    timestamps()
  end

  def changeset(user_feed_source, attrs) do
    user_feed_source
    |> cast(attrs, [:user_id, :feed_source_id])
    |> validate_required([:user_id, :feed_source_id])
    |> unique_constraint([:user_id, :feed_source_id])
  end
end
