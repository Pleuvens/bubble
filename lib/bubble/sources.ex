defmodule Bubble.Sources do
  import Ecto.Query

  alias Bubble.Feeds.FeedSource
  alias Bubble.Feeds.UserFeedSource
  alias Bubble.Repo

  @doc """
  Lists all feed sources (global).
  """
  def list_sources do
    Repo.all(FeedSource)
  end

  @doc """
  Lists all feed sources for a specific user with their subscription details.
  Returns a list of tuples: {feed_source, user_feed_source}
  """
  def list_user_sources(user_id) do
    from(fs in FeedSource,
      join: ufs in UserFeedSource,
      on: ufs.feed_source_id == fs.id,
      where: ufs.user_id == ^user_id,
      order_by: [desc: ufs.created_at],
      select: {fs, ufs}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single feed source by ID.
  """
  def get_source(id) do
    Repo.get(FeedSource, id)
  end

  @doc """
  Gets a single feed source by URL.
  """
  def get_source_by_url(url) do
    Repo.get_by(FeedSource, url: url)
  end

  @doc """
  Creates a new feed source.
  """
  def create_source(attrs) do
    %FeedSource{}
    |> FeedSource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feed source.
  """
  def update_source(source, attrs) do
    source
    |> FeedSource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feed source and all user associations.
  """
  def delete_source(id) do
    Repo.delete_all(from s in FeedSource, where: s.id == ^id)
  end

  @doc """
  Subscribes a user to an existing feed source.
  """
  def add_user_source(user_id, feed_source_id) do
    %UserFeedSource{}
    |> UserFeedSource.changeset(%{
      user_id: user_id,
      feed_source_id: feed_source_id
    })
    |> Repo.insert()
  end

  @doc """
  Creates a new feed source and subscribes the user to it.
  """
  def create_and_add_user_source(user_id, attrs) do
    Repo.transact(fn ->
      with {:ok, source} <- create_source(attrs),
           {:ok, _user_feed_source} <- add_user_source(user_id, source.id) do
        {:ok, source}
      end
    end)
  end

  @doc """
  Unsubscribes a user from a feed source.
  """
  def remove_user_source(user_id, feed_source_id) do
    Repo.delete_all(
      from ufs in UserFeedSource,
        where: ufs.user_id == ^user_id and ufs.feed_source_id == ^feed_source_id
    )
  end

  @doc """
  Checks if a user is subscribed to a feed source.
  """
  def user_subscribed?(user_id, feed_source_id) do
    Repo.exists?(
      from ufs in UserFeedSource,
        where: ufs.user_id == ^user_id and ufs.feed_source_id == ^feed_source_id
    )
  end

  @doc """
  Gets a user's subscription to a feed source.
  """
  def get_user_feed_source(user_id, feed_source_id) do
    Repo.get_by(UserFeedSource, user_id: user_id, feed_source_id: feed_source_id)
  end

  @doc """
  Updates a user's subscription to a feed source (e.g., toggling is_active).
  """
  def update_user_feed_source(user_feed_source, attrs) do
    user_feed_source
    |> UserFeedSource.changeset(attrs)
    |> Repo.update()
  end
end
