defmodule Bubble.NewsSources do
  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo

  @doc """
  Lists all news sources (global).
  """
  def list_sources do
    Repo.all(NewsSource)
  end

  @doc """
  Lists all news sources for a specific user with their subscription details.
  Returns a list of tuples: {news_source, user_news_source}
  """
  def list_user_sources(user_id) do
    from(ns in NewsSource,
      join: uns in UserNewsSource,
      on: uns.news_source_id == ns.id,
      where: uns.user_id == ^user_id,
      order_by: [desc: uns.created_at],
      select: {ns, uns}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single news source by ID.
  """
  def get_source(id) do
    Repo.get(NewsSource, id)
  end

  @doc """
  Gets a single news source by URL.
  """
  def get_source_by_url(url) do
    Repo.get_by(NewsSource, url: url)
  end

  @doc """
  Creates a new news source.
  """
  def create_source(attrs) do
    %NewsSource{}
    |> NewsSource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a news source.
  """
  def update_source(source, attrs) do
    source
    |> NewsSource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a news source and all user associations.
  """
  def delete_source(id) do
    Repo.delete_all(from s in NewsSource, where: s.id == ^id)
  end

  @doc """
  Subscribes a user to an existing news source.
  """
  def add_user_source(user_id, news_source_id) do
    %UserNewsSource{}
    |> UserNewsSource.changeset(%{
      user_id: user_id,
      news_source_id: news_source_id
    })
    |> Repo.insert()
  end

  @doc """
  Creates a new news source and subscribes the user to it.
  """
  def create_and_add_user_source(user_id, attrs) do
    Repo.transact(fn ->
      with {:ok, source} <- create_source(attrs),
           {:ok, _user_news_source} <- add_user_source(user_id, source.id) do
        {:ok, source}
      end
    end)
  end

  @doc """
  Unsubscribes a user from a news source.
  """
  def remove_user_source(user_id, news_source_id) do
    Repo.delete_all(
      from uns in UserNewsSource,
        where: uns.user_id == ^user_id and uns.news_source_id == ^news_source_id
    )
  end

  @doc """
  Checks if a user is subscribed to a news source.
  """
  def user_subscribed?(user_id, news_source_id) do
    Repo.exists?(
      from uns in UserNewsSource,
        where: uns.user_id == ^user_id and uns.news_source_id == ^news_source_id
    )
  end

  @doc """
  Gets a user's subscription to a news source.
  """
  def get_user_news_source(user_id, news_source_id) do
    Repo.get_by(UserNewsSource, user_id: user_id, news_source_id: news_source_id)
  end

  @doc """
  Updates a user's subscription to a news source (e.g., toggling is_active).
  """
  def update_user_news_source(user_news_source, attrs) do
    user_news_source
    |> UserNewsSource.changeset(attrs)
    |> Repo.update()
  end
end
