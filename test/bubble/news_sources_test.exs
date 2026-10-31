defmodule Bubble.NewsSourcesTest do
  use Bubble.DataCase
  use Oban.Testing, repo: Bubble.Repo

  import Bubble.AccountsFixtures
  import Bubble.NewsFixtures

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.NewsSources

  describe "get_featured_source_by_name/1" do
    test "returns a featured source matching the name" do
      source = news_source_fixture(%{name: "NBA Game Recaps", is_featured: true})

      assert found = NewsSources.get_featured_source_by_name("NBA Game Recaps")
      assert found.id == source.id
    end

    test "returns nil when no source exists with that name" do
      assert nil == NewsSources.get_featured_source_by_name("Does Not Exist")
    end

    test "returns nil when source exists but is not featured" do
      news_source_fixture(%{name: "NBA Game Recaps", is_featured: false})

      assert nil == NewsSources.get_featured_source_by_name("NBA Game Recaps")
    end

    test "returns nil when name matches but is_featured is the default (false)" do
      news_source_fixture(%{name: "Hacker News"})

      assert nil == NewsSources.get_featured_source_by_name("Hacker News")
    end
  end

  describe "subscribe_user_and_fetch/2" do
    test "enqueues a fetch when the source has gone stale" do
      user = user_fixture()
      source = news_source_fixture()

      assert {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      assert_enqueued worker: FetchSingleSourceJob, args: %{news_source_id: source.id}
    end

    test "does not enqueue a fetch when the source was fetched recently" do
      user = user_fixture()
      source = news_source_fixture(%{last_fetched_at: DateTime.utc_now()})

      assert {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      refute_enqueued worker: FetchSingleSourceJob
    end
  end

  describe "stamp_newly_orphaned_sources/1" do
    test "stamps sources that have no subscriber" do
      orphan = news_source_fixture()
      now = DateTime.utc_now()

      assert 1 == NewsSources.stamp_newly_orphaned_sources(now)
      assert NewsSources.get_source(orphan.id).orphaned_at == now
    end

    test "leaves subscribed sources alone" do
      user = user_fixture()
      source = news_source_fixture()
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      assert 0 == NewsSources.stamp_newly_orphaned_sources(DateTime.utc_now())
      assert NewsSources.get_source(source.id).orphaned_at == nil
    end

    test "keeps the first stamp when the source is still orphaned" do
      first_stamp = DateTime.add(DateTime.utc_now(), -10, :day)
      orphan = orphaned_news_source_fixture(first_stamp)

      assert 0 == NewsSources.stamp_newly_orphaned_sources(DateTime.utc_now())
      assert NewsSources.get_source(orphan.id).orphaned_at == first_stamp
    end
  end

  describe "clear_orphan_mark_on_subscribed_sources/0" do
    test "clears the stamp when a subscriber came back" do
      user = user_fixture()
      source = orphaned_news_source_fixture(DateTime.utc_now())
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      assert 1 == NewsSources.clear_orphan_mark_on_subscribed_sources()
      assert NewsSources.get_source(source.id).orphaned_at == nil
    end

    test "leaves orphaned sources stamped" do
      stamp = DateTime.utc_now()
      orphan = orphaned_news_source_fixture(stamp)

      assert 0 == NewsSources.clear_orphan_mark_on_subscribed_sources()
      assert NewsSources.get_source(orphan.id).orphaned_at == stamp
    end
  end

  describe "list_source_ids_orphaned_before/1" do
    test "returns only sources stamped before the cutoff" do
      cutoff = DateTime.add(DateTime.utc_now(), -30, :day)
      long_orphaned = orphaned_news_source_fixture(DateTime.add(cutoff, -1, :day))
      orphaned_news_source_fixture(DateTime.add(cutoff, 1, :day))
      news_source_fixture()

      assert [long_orphaned.id] == NewsSources.list_source_ids_orphaned_before(cutoff)
    end
  end
end
