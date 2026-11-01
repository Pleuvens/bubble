defmodule Bubble.NewsSources do
  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo
  alias Bubble.Subscriptions

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

  def create_source_and_subscribe(user_id, attrs) do
    Repo.transact(fn ->
      with {:ok, source} <- create_source(attrs),
           {:ok, _user_news_source} <- Subscriptions.subscribe_user_and_fetch(user_id, source.id) do
        {:ok, source}
      end
    end)
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
end
