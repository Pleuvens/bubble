defmodule Bubble.NewsSources do
  import Ecto.Query

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo

  def list_sources do
    Repo.all(NewsSource)
  end

  def list_user_sources(user_id) do
    from(ns in NewsSource,
      join: uns in UserNewsSource,
      on: uns.news_source_id == ns.id,
      where: uns.user_id == ^user_id,
      order_by: [desc: uns.inserted_at],
      select: {ns, uns}
    )
    |> Repo.all()
  end

  def get_source(id) do
    Repo.get(NewsSource, id)
  end

  def get_source_by_url(url) do
    Repo.get_by(NewsSource, url: url)
  end

  def get_featured_source_by_name(name) do
    Repo.one(from ns in NewsSource, where: ns.name == ^name and ns.is_featured == true, limit: 1)
  end

  def create_source(attrs) do
    %NewsSource{}
    |> NewsSource.changeset(attrs)
    |> Repo.insert()
  end

  def update_source(source, attrs) do
    source
    |> NewsSource.changeset(attrs)
    |> Repo.update()
  end

  def delete_source(id) do
    Repo.delete_all(from s in NewsSource, where: s.id == ^id)
  end

  def add_user_source(user_id, news_source_id) do
    with {:ok, user_news_source} <- insert_user_source(user_id, news_source_id) do
      enqueue_fetch_when_stale(news_source_id)
      {:ok, user_news_source}
    end
  end

  def create_and_add_user_source(user_id, attrs) do
    Repo.transact(fn ->
      with {:ok, source} <- create_source(attrs),
           {:ok, _user_news_source} <- add_user_source(user_id, source.id) do
        {:ok, source}
      end
    end)
  end

  defp insert_user_source(user_id, news_source_id) do
    %UserNewsSource{}
    |> UserNewsSource.changeset(%{
      user_id: user_id,
      news_source_id: news_source_id
    })
    |> Repo.insert()
  end

  defp enqueue_fetch_when_stale(news_source_id) do
    if stale?(news_source_id) do
      %{news_source_id: news_source_id}
      |> FetchSingleSourceJob.new()
      |> Oban.insert()
    end
  end

  defp stale?(news_source_id) do
    NewsSource.due_for_fetch()
    |> where([ns], ns.id == ^news_source_id)
    |> Repo.exists?()
  end

  def remove_user_source(user_id, news_source_id) do
    Repo.delete_all(
      from uns in UserNewsSource,
        where: uns.user_id == ^user_id and uns.news_source_id == ^news_source_id
    )
  end

  def user_subscribed?(user_id, news_source_id) do
    Repo.exists?(
      from uns in UserNewsSource,
        where: uns.user_id == ^user_id and uns.news_source_id == ^news_source_id
    )
  end

  def get_user_news_source(user_id, news_source_id) do
    Repo.get_by(UserNewsSource, user_id: user_id, news_source_id: news_source_id)
  end

  def get_subscribed_source(user_id, news_source_id) do
    Repo.one(
      from ns in NewsSource,
        join: uns in UserNewsSource,
        on: uns.news_source_id == ns.id,
        where: uns.user_id == ^user_id and ns.id == ^news_source_id,
        select: {ns, uns}
    )
  end

  def update_user_news_source(user_news_source, attrs) do
    user_news_source
    |> UserNewsSource.changeset(attrs)
    |> Repo.update()
  end
end
