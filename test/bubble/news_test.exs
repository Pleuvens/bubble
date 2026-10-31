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
      active_source = news_source_fixture(name: "Active Source")
      inactive_source = news_source_fixture(name: "Inactive Source")

      # Subscribe user to both sources
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, active_source.id)
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, inactive_source.id)

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      # Create feeds for both sources
      active_news =
        news_fixture(
          title: "News from Active Source",
          news_source_id: active_source.id,
          published_at: DateTime.add(now, -1, :hour)
        )

      inactive_news =
        news_fixture(
          title: "News from Inactive Source",
          news_source_id: inactive_source.id,
          published_at: DateTime.add(now, -2, :hour)
        )

      # Deactivate the second source
      user_news_source = NewsSources.get_user_news_source(user.id, inactive_source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      # Should only include news from active source
      assert length(news) == 1
      assert hd(news).id == active_news.id
      assert hd(news).title == "News from Active Source"
      refute Enum.any?(news, fn n -> n.id == inactive_news.id end)
    end

    test "returns empty list when all subscriptions are inactive", %{user: user} do
      # Create feed source
      source = news_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      # Create feed
      news_fixture(title: "Test News", news_source_id: source.id)

      # Deactivate subscription
      user_news_source = NewsSources.get_user_news_source(user.id, source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      assert news == []
    end

    test "returns news from multiple active subscriptions", %{user: user} do
      # Create three feed sources
      source1 = news_source_fixture(name: "Source 1")
      source2 = news_source_fixture(name: "Source 2")
      source3 = news_source_fixture(name: "Source 3")

      # Subscribe user to all three
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source1.id)
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source2.id)
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source3.id)

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      # Create feeds for all sources
      news1 =
        news_fixture(
          title: "News 1",
          news_source_id: source1.id,
          published_at: DateTime.add(now, -1, :hour)
        )

      news2 =
        news_fixture(
          title: "News 2",
          news_source_id: source2.id,
          published_at: DateTime.add(now, -2, :hour)
        )

      news3 =
        news_fixture(
          title: "News 3",
          news_source_id: source3.id,
          published_at: DateTime.add(now, -3, :hour)
        )

      # Deactivate source2
      user_news_source2 = NewsSources.get_user_news_source(user.id, source2.id)
      {:ok, _} = NewsSources.update_user_news_source(user_news_source2, %{is_active: false})

      # Get user news
      news = News.list_user_news(user.id)

      # Should include news from source1 and source3, but not source2
      assert length(news) == 2
      news_ids = Enum.map(news, & &1.id)
      assert news1.id in news_ids
      assert news3.id in news_ids
      refute news2.id in news_ids
    end

    test "returns news ordered by published_at descending", %{user: user} do
      # Create feed source
      source = news_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      # Create feeds with different publish dates
      old_news =
        news_fixture(
          title: "Old News",
          news_source_id: source.id,
          published_at: DateTime.add(now, -3, :hour)
        )

      recent_news =
        news_fixture(
          title: "Recent News",
          news_source_id: source.id,
          published_at: DateTime.add(now, -1, :hour)
        )

      middle_news =
        news_fixture(
          title: "Middle News",
          news_source_id: source.id,
          published_at: DateTime.add(now, -2, :hour)
        )

      # Get user news
      news = News.list_user_news(user.id)

      # Should be ordered by published_at descending
      assert length(news) == 3
      assert Enum.at(news, 0).id == recent_news.id
      assert Enum.at(news, 1).id == middle_news.id
      assert Enum.at(news, 2).id == old_news.id
    end

    test "limits results to 50 items", %{user: user} do
      source = news_source_fixture()
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      for i <- 1..60 do
        news_fixture(
          title: "News #{i}",
          news_source_id: source.id,
          published_at: DateTime.add(now, -i, :minute)
        )
      end

      news = News.list_user_news(user.id)

      assert length(news) == 50
    end

    test "returns empty list when user has no subscriptions", %{user: user} do
      # Create feed source and feed but don't subscribe user
      source = news_source_fixture()
      news_fixture(news_source_id: source.id)

      # Get user news
      news = News.list_user_news(user.id)

      assert news == []
    end

    test "reactivating a subscription shows its news again", %{user: user} do
      # Create feed source
      source = news_source_fixture()

      # Subscribe user
      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)

      # Create feed
      created_news = news_fixture(title: "Test News", news_source_id: source.id)

      # Initially should see the feed
      news = News.list_user_news(user.id)
      assert length(news) == 1
      assert hd(news).id == created_news.id

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
      assert hd(news).id == created_news.id
    end
  end

  describe "list_user_news/1 source overrides" do
    setup do
      user = user_fixture()
      other_user = user_fixture()
      source = news_source_fixture(name: "Shared Name", description: "Shared description")

      {:ok, _} = NewsSources.subscribe_user_and_fetch(user.id, source.id)
      {:ok, _} = NewsSources.subscribe_user_and_fetch(other_user.id, source.id)

      news_fixture(
        title: "An article",
        news_source_id: source.id,
        published_at: DateTime.utc_now() |> DateTime.truncate(:second)
      )

      {:ok, user: user, other_user: other_user, source: source}
    end

    test "shows the subscriber's own name and description", %{user: user, source: source} do
      user_source = NewsSources.get_user_news_source(user.id, source.id)

      {:ok, _} =
        NewsSources.update_user_news_source(user_source, %{
          custom_name: "My Name",
          custom_description: "My description"
        })

      news = News.list_user_news(user.id)

      assert hd(news).news_source.name == "My Name"
      assert hd(news).news_source.description == "My description"
    end

    test "leaves another subscriber on the shared name", %{
      user: user,
      other_user: other_user,
      source: source
    } do
      user_source = NewsSources.get_user_news_source(user.id, source.id)
      {:ok, _} = NewsSources.update_user_news_source(user_source, %{custom_name: "My Name"})

      news = News.list_user_news(other_user.id)

      assert hd(news).news_source.name == "Shared Name"
      assert hd(news).news_source.description == "Shared description"
    end

    test "uses the shared name when nothing is overridden", %{user: user} do
      news = News.list_user_news(user.id)

      assert hd(news).news_source.name == "Shared Name"
    end
  end
end
