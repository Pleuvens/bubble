defmodule Bubble.Sources.NewsProcessorTest do
  use Bubble.DataCase, async: false

  alias Bubble.News.News
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Repo

  import Bubble.NewsFixtures

  setup do
    source = news_source_fixture()
    {:ok, source: source}
  end

  describe "process_and_save_news/2 - video items" do
    test "uses RSS description directly for video items, skipping MetaScraper", %{source: source} do
      Req.Test.stub(Bubble.Sources.HttpClient, fn _conn ->
        raise "MetaScraper should not be called for video items"
      end)

      items = [
        %{
          title: "Lakers vs Celtics | Game Recap",
          url: "https://www.youtube.com/watch?v=abc123",
          description: "Full game recap from last night.",
          content: "",
          published_at: "2026-04-29T12:00:00Z",
          video_id: "abc123",
          thumbnail_url: "https://i.ytimg.com/vi/abc123/maxresdefault.jpg"
        }
      ]

      assert :ok = NewsProcessor.process_and_save_news(items, source)

      news = Repo.one(News)
      assert news.content == "Full game recap from last night."
      assert news.video_id == "abc123"
      assert news.thumbnail_url == "https://i.ytimg.com/vi/abc123/maxresdefault.jpg"
    end

    test "uses empty string when video item has no description", %{source: source} do
      Req.Test.stub(Bubble.Sources.HttpClient, fn _conn ->
        raise "MetaScraper should not be called for video items"
      end)

      items = [
        %{
          title: "Game Recap",
          url: "https://www.youtube.com/watch?v=xyz",
          description: "",
          content: "",
          published_at: "2026-04-29T12:00:00Z",
          video_id: "xyz",
          thumbnail_url: ""
        }
      ]

      assert :ok = NewsProcessor.process_and_save_news(items, source)
      assert Repo.one(News).content == ""
    end

    test "falls back to MetaScraper for non-video items with no content", %{source: source} do
      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Scraped description\"></head></html>"
        )
      end)

      items = [
        %{
          title: "Article",
          url: "https://example.com/article",
          description: "",
          content: "",
          published_at: "2026-04-29T12:00:00Z",
          video_id: "",
          thumbnail_url: ""
        }
      ]

      assert :ok = NewsProcessor.process_and_save_news(items, source)
      assert Repo.one(News).content == "Scraped description"
    end

    test "prefers RSS content over description for non-video items", %{source: source} do
      items = [
        %{
          title: "Article",
          url: "https://example.com/article",
          description: "Short description",
          content: "This is the full article content with enough length to qualify.",
          published_at: "2026-04-29T12:00:00Z",
          video_id: "",
          thumbnail_url: ""
        }
      ]

      assert :ok = NewsProcessor.process_and_save_news(items, source)
      assert Repo.one(News).content == "This is the full article content with enough length to qualify."
    end
  end
end
