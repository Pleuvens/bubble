defmodule Bubble.Feeds do
  import Ecto.Query

  alias Bubble.Feeds.Feed
  alias Bubble.Feeds.UserFeedSource
  alias Bubble.Repo

  @doc """
  Lists all news (for backward compatibility or admin views).
  """
  def list_news do
    Repo.all(
      from(f in Feed,
        order_by: [desc: f.published_at],
        limit: 10
      )
    )
  end

  @doc """
  Lists news from sources the user is subscribed to.
  """
  def list_user_news(user_id) do
    Repo.all(
      from(f in Feed,
        join: ufs in UserFeedSource,
        on: ufs.feed_source_id == f.feed_source_id,
        where: ufs.user_id == ^user_id,
        order_by: [desc: f.published_at],
        limit: 10
      )
    )
  end
end
