defmodule BubbleWeb.PageControllerTest do
  use BubbleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bubble.NewsFixtures

  setup :register_and_log_in_user

  test "GET / redirects to feed with user's subscribed news", %{conn: conn, user: user} do
    # Create a feed source, subscribe the user, and add a feed item
    feed_source = feed_source_fixture()
    subscribe_user_to_source(user.id, feed_source.id)

    feed_fixture(
      title: "Test News",
      description: "Test description",
      content: "Test content",
      news_source_id: feed_source.id
    )

    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Test News"
  end

  test "GET / shows no news for unauthenticated users", %{conn: _} do
    # Create an unauthenticated connection
    conn = build_conn()

    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Welcome to Bubble"
  end
end
