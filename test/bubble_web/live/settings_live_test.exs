defmodule BubbleWeb.SettingsLiveTest do
  use BubbleWeb.ConnCase

  import Ecto.Query
  import Phoenix.LiveViewTest
  import Bubble.NewsFixtures

  alias Bubble.NewsSources
  alias Bubble.Repo

  setup :register_and_log_in_user

  describe "Discover section - unsubscribed state" do
    test "shows Subscribe button for each featured source", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/settings")

      assert html =~ "NBA Game Recaps"
      assert has_element?(view, "button[phx-click='subscribe_featured']")
    end

    test "shows Video badge for video sources", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/settings")
      assert html =~ "Video"
    end

    test "does not show toggle when not subscribed", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      refute has_element?(view, "button[phx-click='toggle_active']")
    end
  end

  describe "Discover section - subscribe_featured" do
    test "creates source with is_featured true and subscribes user", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      view |> element("button[phx-click='subscribe_featured']") |> render_click()

      source = NewsSources.get_featured_source_by_name("NBA Game Recaps")
      assert source != nil
      assert source.is_featured == true
      assert NewsSources.user_subscribed?(user.id, source.id)
    end

    test "shows toggle after subscribing, no longer shows Subscribe button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      view |> element("button[phx-click='subscribe_featured']") |> render_click()

      refute has_element?(view, "button[phx-click='subscribe_featured']")
      assert has_element?(view, "button[phx-click='toggle_active']")
    end

    test "reuses existing featured source instead of creating a duplicate", %{
      conn: conn,
      user: user
    } do
      existing =
        news_source_fixture(%{
          name: "NBA Game Recaps",
          url: "https://www.youtube.com/feeds/videos.xml?playlist_id=XYZ",
          content_type: :video,
          is_featured: true
        })

      {:ok, view, _html} = live(conn, ~p"/settings")
      view |> element("button[phx-click='subscribe_featured']") |> render_click()

      count =
        Repo.aggregate(
          from(s in Bubble.News.NewsSource, where: s.name == "NBA Game Recaps"),
          :count
        )

      assert count == 1
      assert NewsSources.user_subscribed?(user.id, existing.id)
    end
  end

  describe "Discover section - subscribed state controls" do
    setup %{user: user} do
      source =
        news_source_fixture(%{
          name: "NBA Game Recaps",
          url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCWJ2lWNubArHWmf3FIHbfcQ",
          content_type: :video,
          is_featured: true
        })

      {:ok, _} = NewsSources.add_user_source(user.id, source.id)
      {:ok, source: source}
    end

    test "shows toggle instead of Subscribe button", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/settings")

      refute html =~ "phx-click=\"subscribe_featured\""
      assert has_element?(view, "button[phx-click='toggle_active']")
    end

    test "toggle updates active state", %{conn: conn, user: user, source: source} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      # Source is active by default; toggle to inactive
      view |> element("button[phx-click='toggle_active']") |> render_click()

      user_source = NewsSources.get_user_news_source(user.id, source.id)
      assert user_source.is_active == false
    end

    test "edit pencil shows URL input form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      view |> element("button[phx-click='edit_featured']") |> render_click()

      assert has_element?(view, "form[phx-submit='save_featured_url']")
      assert has_element?(view, "input[name='url']")
    end

    test "save_featured_url updates the user's custom_url, not the shared source URL", %{
      conn: conn,
      source: source,
      user: user
    } do
      new_url = "https://www.youtube.com/feeds/videos.xml?playlist_id=NEWPLAYLIST"
      {:ok, view, _html} = live(conn, ~p"/settings")

      view |> element("button[phx-click='edit_featured']") |> render_click()

      view
      |> form("form[phx-submit='save_featured_url']", %{url: new_url})
      |> render_submit()

      user_source =
        Repo.get_by(Bubble.News.UserNewsSource, user_id: user.id, news_source_id: source.id)

      assert user_source.custom_url == new_url

      # Shared source URL must remain unchanged
      shared = Repo.get(Bubble.News.NewsSource, source.id)

      assert shared.url ==
               "https://www.youtube.com/feeds/videos.xml?channel_id=UCWJ2lWNubArHWmf3FIHbfcQ"
    end

    test "cancel_edit_featured hides the URL form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings")

      view |> element("button[phx-click='edit_featured']") |> render_click()
      assert has_element?(view, "form[phx-submit='save_featured_url']")

      view |> element("button[phx-click='cancel_edit_featured']") |> render_click()
      refute has_element?(view, "form[phx-submit='save_featured_url']")
    end
  end

  describe "RSS Sources list" do
    test "featured sources do not appear in RSS Sources list", %{conn: conn, user: user} do
      news_source_fixture(%{
        name: "NBA Game Recaps",
        url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCWJ2lWNubArHWmf3FIHbfcQ",
        content_type: :video,
        is_featured: true
      })
      |> then(fn source -> NewsSources.add_user_source(user.id, source.id) end)

      regular = news_source_fixture(%{name: "Hacker News", url: "https://hnrss.org/frontpage"})
      NewsSources.add_user_source(user.id, regular.id)

      {:ok, _view, html} = live(conn, ~p"/settings")

      # Hacker News appears in the RSS Sources list section
      assert html =~ "Hacker News"
      # NBA appears only in the Discover section — exactly one toggle_active for NBA
      # (in Discover card), not a second one in the RSS Sources list
      toggle_count =
        html |> String.split("phx-click=\"toggle_active\"") |> length() |> Kernel.-(1)

      assert toggle_count == 2
    end

    test "manually added sources appear in RSS Sources list", %{conn: conn, user: user} do
      source = news_source_fixture(%{name: "My Blog", url: "https://myblog.com/rss"})
      NewsSources.add_user_source(user.id, source.id)

      {:ok, _view, html} = live(conn, ~p"/settings")

      assert html =~ "My Blog"
    end
  end
end
