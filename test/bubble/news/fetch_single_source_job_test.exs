defmodule Bubble.News.FetchSingleSourceJobTest do
  use Bubble.DataCase, async: false

  alias Bubble.News.{News, NewsSource, FetchSingleSourceJob}
  alias Bubble.Repo

  setup do
    Repo.delete_all(News)
    Repo.delete_all(NewsSource)
    :ok
  end

  describe "perform/1" do
    test "successfully fetches a single RSS feed" do
      source =
        insert_news_source(%{
          name: "Test Source",
          url: "https://example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed("https://example.com/news/1"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      assert Repo.aggregate(News, :count) == 1
      news_item = Repo.one(News)
      assert news_item.news_source_id == source.id
      assert news_item.title == "Test News Item"
      assert news_item.url == "https://example.com/news/1"

      updated_source = Repo.get(NewsSource, source.id)
      assert updated_source.last_fetched_at
      assert DateTime.diff(DateTime.utc_now(), updated_source.last_fetched_at) < 5
    end

    test "handles non-existent news source" do
      non_existent_id = Ecto.UUID.generate()
      job = %Oban.Job{args: %{"news_source_id" => non_existent_id}}

      assert {:error, :source_not_found} = FetchSingleSourceJob.perform(job)
      assert Repo.aggregate(News, :count) == 0
    end

    test "handles RSS feed fetch errors" do
      source =
        insert_news_source(%{
          name: "Failing Source",
          url: "https://failing.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.text("Internal Server Error")
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert {:error, _} = FetchSingleSourceJob.perform(job)

      assert Repo.aggregate(News, :count) == 0
      updated_source = Repo.get(NewsSource, source.id)
      assert is_nil(updated_source.last_fetched_at)
    end

    test "handles MetaScraper errors gracefully" do
      source =
        insert_news_source(%{
          name: "Test Source",
          url: "https://test.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed("https://example.com/news/2"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.html("<html></html>")
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      news_item = Repo.one(News)
      assert news_item.content == "No description available"
    end

    test "parses valid published_at dates" do
      source =
        insert_news_source(%{
          name: "Test Source",
          url: "https://test2.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed("https://example.com/news/3"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      news_item = Repo.one(News)
      assert news_item.published_at == DateTime.from_iso8601("2025-08-01T12:00:00Z") |> elem(1)
    end

    test "handles invalid published_at dates by using current time" do
      source =
        insert_news_source(%{
          name: "Test Source",
          url: "https://test3.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed_with_invalid_date("https://example.com/news/4"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      news_item = Repo.one(News)
      assert DateTime.diff(DateTime.utc_now(), news_item.published_at) < 5
    end

    test "fetches multiple news items from a single feed" do
      source =
        insert_news_source(%{
          name: "Multi Item Source",
          url: "https://multi.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed_with_multiple_items())
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      assert Repo.aggregate(News, :count) == 3
      news_items = Repo.all(News)
      assert Enum.all?(news_items, fn item -> item.news_source_id == source.id end)
    end

    test "uses RSS content when available" do
      source =
        insert_news_source(%{
          name: "Content Source",
          url: "https://content.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed_with_content("https://example.com/news/5"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"This should not be used\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert :ok = FetchSingleSourceJob.perform(job)

      news_item = Repo.one(News)
      assert news_item.content == "This is substantial RSS content that should be used directly"
    end

    test "returns error when feed has no valid items" do
      source =
        insert_news_source(%{
          name: "Empty Feed Source",
          url: "https://empty.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_empty_rss_feed())
      end)

      job = %Oban.Job{args: %{"news_source_id" => source.id}}
      assert {:error, :rss_parsing_failed} = FetchSingleSourceJob.perform(job)

      # Timestamp should not be updated when fetch fails
      assert Repo.aggregate(News, :count) == 0
      updated_source = Repo.get(NewsSource, source.id)
      assert is_nil(updated_source.last_fetched_at)
    end
  end

  defp insert_news_source(attrs) do
    %NewsSource{}
    |> NewsSource.changeset(attrs)
    |> Repo.insert!()
  end

  defp mock_rss_feed(news_url) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Test Feed</title>
      <entry>
        <title>Test News Item</title>
        <link href="#{news_url}" />
        <published>2025-08-01T12:00:00Z</published>
        <summary>Test description</summary>
      </entry>
    </feed>
    """
  end

  defp mock_rss_feed_with_invalid_date(news_url) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Test Feed</title>
      <entry>
        <title>Test News Item</title>
        <link href="#{news_url}" />
        <published>invalid-date</published>
        <summary>Test description</summary>
      </entry>
    </feed>
    """
  end

  defp mock_rss_feed_with_multiple_items do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Multi Item Feed</title>
      <entry>
        <title>News Item 1</title>
        <link href="https://example.com/news/1" />
        <published>2025-08-01T12:00:00Z</published>
        <summary>Description 1</summary>
      </entry>
      <entry>
        <title>News Item 2</title>
        <link href="https://example.com/news/2" />
        <published>2025-08-02T12:00:00Z</published>
        <summary>Description 2</summary>
      </entry>
      <entry>
        <title>News Item 3</title>
        <link href="https://example.com/news/3" />
        <published>2025-08-03T12:00:00Z</published>
        <summary>Description 3</summary>
      </entry>
    </feed>
    """
  end

  defp mock_rss_feed_with_content(news_url) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Content Feed</title>
      <entry>
        <title>News with Content</title>
        <link href="#{news_url}" />
        <published>2025-08-01T12:00:00Z</published>
        <summary>Short description</summary>
        <content>This is substantial RSS content that should be used directly</content>
      </entry>
    </feed>
    """
  end

  defp mock_empty_rss_feed do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Empty Feed</title>
    </feed>
    """
  end
end
