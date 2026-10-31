defmodule Bubble.News.DeleteOrphanedSourcesJob do
  use Oban.Worker

  alias Bubble.NewsSources

  require Logger

  @grace_period_days 30

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    now = DateTime.utc_now()

    NewsSources.clear_orphan_mark_on_subscribed_sources()
    NewsSources.stamp_newly_orphaned_sources(now)

    deleted_count = delete_sources_orphaned_before(grace_period_cutoff(now))

    {:ok, %{deleted_count: deleted_count}}
  end

  defp grace_period_cutoff(now) do
    DateTime.add(now, -@grace_period_days, :day)
  end

  defp delete_sources_orphaned_before(cutoff) do
    cutoff
    |> NewsSources.list_source_ids_orphaned_before()
    |> Enum.map(fn source_id ->
      Logger.info("Deleting orphaned news source", news_source_id: source_id)
      NewsSources.delete_source(source_id)
    end)
    |> length()
  end
end
