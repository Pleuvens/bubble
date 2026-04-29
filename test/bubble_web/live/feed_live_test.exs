defmodule BubbleWeb.FeedLiveTest do
  use BubbleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bubble.NewsFixtures

  setup :register_and_log_in_user

  describe "mount/3" do
    test "mounts successfully with news data", %{conn: conn, user: user} do
      {_feed_source, _feed} = insert_test_feed_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title"
    end

    test "mounts with empty news list when no feeds exist", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "settings"
      refute html =~ "news-item-"
    end

    test "only shows feeds from subscribed sources", %{conn: conn, user: user} do
      {_feed_source, _feed} =
        insert_test_feed_with_subscription(user.id, title: "Subscribed Feed")

      other_source = feed_source_fixture(name: "Other Source")
      feed_fixture(title: "Unsubscribed Feed", news_source_id: other_source.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Subscribed Feed"
      refute html =~ "Unsubscribed Feed"
    end

    test "assigns initial state correctly", %{conn: conn, user: user} do
      {_feed_source, _feed} = insert_test_feed_with_subscription(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "[data-active='0']")
    end
  end

  describe "handle_event/3 - set_index" do
    test "sets current_index correctly", %{conn: conn, user: user} do
      insert_multiple_test_feeds_with_subscription(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "[data-active='0']")

      assert render_hook(view, "set_index", %{"index" => 2}) =~ "Test News Title"
    end

    test "clamps index to valid range", %{conn: conn, user: user} do
      insert_multiple_test_feeds_with_subscription(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "set_index", %{"index" => 999})
      assert has_element?(view, "[data-active='2']")

      render_hook(view, "set_index", %{"index" => -5})
      assert has_element?(view, "[data-active='0']")
    end
  end

  describe "render/1" do
    test "displays news content directly without expand", %{conn: conn, user: user} do
      {_feed_source, _feed} = insert_test_feed_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test description for the news article"
    end

    test "displays external link to article source", %{conn: conn, user: user} do
      {_feed_source, feed} = insert_test_feed_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "href=\"#{feed.url}\""
      assert html =~ "target=\"_blank\""
    end

    test "displays published date", %{conn: conn, user: user} do
      {_feed_source, _feed} = insert_test_feed_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      year = DateTime.utc_now().year |> Integer.to_string()
      assert html =~ year
    end

    test "renders multiple news items", %{conn: conn, user: user} do
      insert_multiple_test_feeds_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title 1"
      assert html =~ "Test News Title 2"
      assert html =~ "Test News Title 3"
    end

    test "includes keyboard navigation hint", %{conn: conn, user: user} do
      {_feed_source, _feed} = insert_test_feed_with_subscription(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "navigate"
      assert html =~ "open"
    end

    test "shows empty state prompt when no news", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "settings"
    end
  end

  describe "integration tests" do
    test "browse news items with keyboard nav", %{conn: conn, user: user} do
      insert_multiple_test_feeds_with_subscription(user.id)

      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title 1"
      assert html =~ "Test News Title 2"

      render_hook(view, "set_index", %{"index" => 1})
      assert has_element?(view, "[data-active='1']")
    end
  end

  # Helper functions
  defp insert_test_feed_with_subscription(user_id, attrs \\ []) do
    feed_source = feed_source_fixture()
    subscribe_user_to_source(user_id, feed_source.id)

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    feed_attrs =
      Keyword.merge(
        [
          title: "Test News Title",
          description: "Test description for the news article",
          content: "Test content for the news article",
          published_at: now,
          news_source_id: feed_source.id
        ],
        attrs
      )

    feed = feed_fixture(feed_attrs)
    {feed_source, feed}
  end

  defp insert_multiple_test_feeds_with_subscription(user_id) do
    feed_source = feed_source_fixture()
    subscribe_user_to_source(user_id, feed_source.id)

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    for i <- 1..3 do
      feed_fixture(
        title: "Test News Title #{i}",
        description: "Test description for the news article #{i}",
        content: "Test content for the news article #{i}",
        published_at: DateTime.add(now, -i, :minute),
        news_source_id: feed_source.id
      )
    end
  end
end
