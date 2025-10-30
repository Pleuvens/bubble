defmodule BubbleWeb.PageControllerTest do
  use BubbleWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bubble.Feeds.Feed
  alias Bubble.Repo

  test "GET / redirects to feed", %{conn: conn} do
    # Insert a test feed to ensure the page renders
    %Feed{
      title: "Test News",
      description: "Test description",
      content: "Test content",
      url: "https://example.com/test",
      published_at: ~U[2024-01-01 00:00:00Z]
    }
    |> Repo.insert!()

    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Test News"
  end
end
