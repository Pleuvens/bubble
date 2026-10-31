defmodule Bubble.NewsSources do
  import Ecto.Query

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo

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

  def stamp_newly_orphaned_sources(orphaned_at) do
    {stamped_count, _} =
      sources_without_subscription()
      |> where([source: ns], is_nil(ns.orphaned_at))
      |> Repo.update_all(set: [orphaned_at: orphaned_at])

    stamped_count
  end

  def clear_orphan_mark_on_subscribed_sources do
    {cleared_count, _} =
      sources_with_subscription()
      |> where([source: ns], not is_nil(ns.orphaned_at))
      |> Repo.update_all(set: [orphaned_at: nil])

    cleared_count
  end

  def list_source_ids_orphaned_before(cutoff) do
    Repo.all(
      from ns in NewsSource,
        where: not is_nil(ns.orphaned_at) and ns.orphaned_at < ^cutoff,
        select: ns.id
    )
  end

  defp sources_without_subscription do
    from ns in NewsSource, as: :source, where: not exists(subscriptions_of_source())
  end

  defp sources_with_subscription do
    from ns in NewsSource, as: :source, where: exists(subscriptions_of_source())
  end

  defp subscriptions_of_source do
    from uns in UserNewsSource,
      where: uns.news_source_id == parent_as(:source).id,
      select: 1
  end

  def subscribe_user_and_fetch(user_id, news_source_id) do
    with {:ok, user_news_source} <- insert_user_source(user_id, news_source_id) do
      enqueue_fetch_when_stale(news_source_id)
      {:ok, user_news_source}
    end
  end

  def create_source_and_subscribe(user_id, attrs) do
    Repo.transact(fn ->
      with {:ok, source} <- create_source(attrs),
           {:ok, _user_news_source} <- subscribe_user_and_fetch(user_id, source.id) do
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
