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
end
