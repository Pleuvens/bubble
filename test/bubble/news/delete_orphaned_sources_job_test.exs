defmodule Bubble.News.DeleteOrphanedSourcesJobTest do
  use Bubble.DataCase

  import Bubble.AccountsFixtures
  import Bubble.NewsFixtures

  alias Bubble.News.DeleteOrphanedSourcesJob
  alias Bubble.NewsSources
  alias Bubble.Subscriptions

  describe "perform/1" do
    test "stamps a source that just lost its last subscriber" do
      source = news_source_fixture()

      assert {:ok, %{deleted_count: 0}} = perform_job()
      assert NewsSources.get_source(source.id).orphaned_at != nil
    end

    test "clears the stamp when a subscriber came back" do
      user = user_fixture()
      source = orphaned_news_source_fixture(days_ago(40))
      {:ok, _} = Subscriptions.subscribe_user_and_fetch(user.id, source.id)

      assert {:ok, %{deleted_count: 0}} = perform_job()
      assert NewsSources.get_source(source.id).orphaned_at == nil
    end

    test "deletes a source orphaned longer than the grace period" do
      source = orphaned_news_source_fixture(days_ago(31))
      news_fixture(%{news_source_id: source.id})

      assert {:ok, %{deleted_count: 1}} = perform_job()
      assert NewsSources.get_source(source.id) == nil
    end

    test "keeps a source still inside the grace period" do
      source = orphaned_news_source_fixture(days_ago(29))

      assert {:ok, %{deleted_count: 0}} = perform_job()
      assert NewsSources.get_source(source.id) != nil
    end
  end

  defp perform_job do
    DeleteOrphanedSourcesJob.perform(%Oban.Job{args: %{}})
  end

  defp days_ago(days) do
    DateTime.add(DateTime.utc_now(), -days, :day)
  end
end
