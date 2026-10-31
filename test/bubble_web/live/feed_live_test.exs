defmodule BubbleWeb.FeedLiveTest do
  use BubbleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bubble.NewsFixtures

  setup :register_and_log_in_user

  describe "mount/3" do
    test "mounts successfully with news data", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title"
    end

    test "mounts with empty news list when no feeds exist", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "settings"
      refute html =~ "news-item-"
    end

    test "only shows feeds from subscribed sources", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id, title: "Subscribed Feed")

      other_source = news_source_fixture(name: "Other Source")
      news_fixture(title: "Unsubscribed Feed", news_source_id: other_source.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Subscribed Feed"
      refute html =~ "Unsubscribed Feed"
    end

    test "assigns initial state correctly", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "[data-active='0']")
    end
  end

  describe "mount/3 - unauthenticated" do
    test "shows the landing page instead of news", %{conn: _} do
      conn = build_conn()

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Your feed, your way."
    end
  end

  describe "handle_event/3 - set_index" do
    test "sets current_index correctly", %{conn: conn, user: user} do
      subscribed_news_list_fixture(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "[data-active='0']")

      assert render_hook(view, "set_index", %{"index" => 2}) =~ "Test News Title"
    end

    test "clamps index to valid range", %{conn: conn, user: user} do
      subscribed_news_list_fixture(user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "set_index", %{"index" => 999})
      assert has_element?(view, "[data-active='2']")

      render_hook(view, "set_index", %{"index" => -5})
      assert has_element?(view, "[data-active='0']")
    end
  end

  describe "render/1" do
    test "displays news content directly without expand", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test description for the news article"
    end

    test "displays external link to article source", %{conn: conn, user: user} do
      {_news_source, news} = subscribed_news_fixture(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "href=\"#{news.url}\""
      assert html =~ "target=\"_blank\""
    end

    test "displays published date", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      year = DateTime.utc_now().year |> Integer.to_string()
      assert html =~ year
    end

    test "renders multiple news items", %{conn: conn, user: user} do
      subscribed_news_list_fixture(user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title 1"
      assert html =~ "Test News Title 2"
      assert html =~ "Test News Title 3"
    end

    test "includes keyboard navigation hint", %{conn: conn, user: user} do
      {_news_source, _news} = subscribed_news_fixture(user.id)

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
      subscribed_news_list_fixture(user.id)

      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Test News Title 1"
      assert html =~ "Test News Title 2"

      render_hook(view, "set_index", %{"index" => 1})
      assert has_element?(view, "[data-active='1']")
    end
  end
end
