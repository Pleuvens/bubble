defmodule Bubble.NewsTest do
  use Bubble.DataCase

  import Bubble.AccountsFixtures
  import Bubble.NewsFixtures

  alias Bubble.News
  alias Bubble.NewsSources

  describe "list_user_news/1" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "returns news from active subscriptions only", %{user: user} do
      # Create two feed sources
      active_source = feed_source_fixture(name: "Active Source")
      inactive_source = feed_source_fixture(name: "Inactive Source")

      # Subscribe user to both sources
      {:ok, _} = NewsSources.add_user_source(user.id, active_source.id)
      {:ok, _} = NewsSources.add_user_source(user.id, inactive_source.id)

      # Create feeds for both sources
      active_feed =
        feed_fixture(
          title: "News from Active Source",
          news_source_id: active_source.id,
          published_at: ~U[2024-01-02 00:00:00Z]
        )

      inactive_feed =
        feed_fixture(
          title: "News from Inactive Source",
          news_source_id: inactive_source.id,
          published_at: ~U[2024-01-01 00:00:00Z]
        )

      # Deactivate the second source
      user_news_source = NewsSources.get_user_news_source(user.id, inactive_source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      # Should only include news from active source
      assert length(news) == 1
      assert hd(news).id == active_feed.id
      assert hd(news).title == "News from Active Source"
      refute Enum.any?(news, fn n -> n.id == inactive_feed.id end)
    end

    test "returns empty list when all subscriptions are inactive", %{user: user} do
      # Create feed source
      source = feed_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.add_user_source(user.id, source.id)

      # Create feed
      feed_fixture(title: "Test News", news_source_id: source.id)

      # Deactivate subscription
      user_news_source = NewsSources.get_user_news_source(user.id, source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      assert news == []
    end

    test "returns news from multiple active subscriptions", %{user: user} do
      # Create three feed sources
      source1 = feed_source_fixture(name: "Source 1")
      source2 = feed_source_fixture(name: "Source 2")
      source3 = feed_source_fixture(name: "Source 3")

      # Subscribe user to all three
      {:ok, _} = NewsSources.add_user_source(user.id, source1.id)
      {:ok, _} = NewsSources.add_user_source(user.id, source2.id)
      {:ok, _} = NewsSources.add_user_source(user.id, source3.id)

      # Create feeds for all sources
      feed1 =
        feed_fixture(
          title: "News 1",
          news_source_id: source1.id,
          published_at: ~U[2024-01-03 00:00:00Z]
        )

      feed2 =
        feed_fixture(
          title: "News 2",
          news_source_id: source2.id,
          published_at: ~U[2024-01-02 00:00:00Z]
        )

      feed3 =
        feed_fixture(
          title: "News 3",
          news_source_id: source3.id,
          published_at: ~U[2024-01-01 00:00:00Z]
        )

      # Deactivate source2
      user_news_source2 = NewsSources.get_user_news_source(user.id, source2.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source2, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      # Should include news from source1 and source3, but not source2
      assert length(news) == 2
      news_ids = Enum.map(news, & &1.id)
      assert feed1.id in news_ids
      assert feed3.id in news_ids
      refute feed2.id in news_ids
    end

    test "returns news ordered by published_at descending", %{user: user} do
      # Create feed source
      source = feed_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.add_user_source(user.id, source.id)

      # Create feeds with different publish dates
      old_feed =
        feed_fixture(
          title: "Old News",
          news_source_id: source.id,
          published_at: ~U[2024-01-01 00:00:00Z]
        )

      recent_feed =
        feed_fixture(
          title: "Recent News",
          news_source_id: source.id,
          published_at: ~U[2024-01-03 00:00:00Z]
        )

      middle_feed =
        feed_fixture(
          title: "Middle News",
          news_source_id: source.id,
          published_at: ~U[2024-01-02 00:00:00Z]
        )

      # Get user news
      news = News.list_user_news(user.id)

      # Should be ordered by published_at descending
      assert length(news) == 3
      assert Enum.at(news, 0).id == recent_feed.id
      assert Enum.at(news, 1).id == middle_feed.id
      assert Enum.at(news, 2).id == old_feed.id
    end

    test "limits results to 10 items", %{user: user} do
      # Create feed source
      source = feed_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.add_user_source(user.id, source.id)

      # Create 15 feeds
      base_time = ~U[2024-01-01 00:00:00Z]

      for i <- 1..15 do
        feed_fixture(
          title: "News #{i}",
          news_source_id: source.id,
          published_at: DateTime.add(base_time, i, :hour)
        )
      end

      # Get user news
      news = News.list_user_news(user.id)

      # Should be limited to 10
      assert length(news) == 10
    end

    test "returns empty list when user has no subscriptions", %{user: user} do
      # Create feed source and feed but don't subscribe user
      source = feed_source_fixture()
      feed_fixture(news_source_id: source.id)

      # Get user news
      news = News.list_user_news(user.id)

      assert news == []
    end

    test "reactivating a subscription shows its news again", %{user: user} do
      # Create feed source
      source = feed_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.add_user_source(user.id, source.id)

      # Create feed
      feed = feed_fixture(title: "Test News", news_source_id: source.id)

      # Initially should see the feed
      news = News.list_user_news(user.id)
      assert length(news) == 1
      assert hd(news).id == feed.id

      # Deactivate subscription
      user_news_source = NewsSources.get_user_news_source(user.id, source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: false})

      # Should not see the feed
      news = News.list_user_news(user.id)
      assert news == []

      # Reactivate subscription
      user_news_source = NewsSources.get_user_news_source(user.id, source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: true})

      # Should see the feed again
      news = News.list_user_news(user.id)
      assert length(news) == 1
      assert hd(news).id == feed.id
    end
  end
end
