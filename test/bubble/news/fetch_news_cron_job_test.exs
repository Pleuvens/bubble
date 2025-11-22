defmodule Bubble.News.FetchNewsCronJobTest do
  use Bubble.DataCase, async: false

  alias Bubble.News.{News, NewsSource, FetchNewsCronJob}
  alias Bubble.Repo

  setup do
    Repo.delete_all(News)
    Repo.delete_all(NewsSource)
    :ok
  end

  describe "perform/1" do
    test "fetches feeds from sources that haven't been fetched recently" do
      old_source =
        insert_news_source(%{
          name: "Old Source",
          url: "https://old.example.com/rss",
          last_fetched_at: DateTime.add(DateTime.utc_now(), -2, :day)
        })

      recent_source =
        insert_news_source(%{
          name: "Recent Source",
          url: "https://recent.example.com/rss",
          last_fetched_at: DateTime.add(DateTime.utc_now(), -12, :hour)
        })

      never_fetched_source =
        insert_news_source(%{
          name: "Never Fetched",
          url: "https://never.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        case conn.host do
          "old.example.com" ->
            Req.Test.text(conn, mock_rss_feed("https://example.com/news/old"))

          "never.example.com" ->
            Req.Test.text(conn, mock_rss_feed("https://example.com/news/never"))

          "recent.example.com" ->
            Req.Test.text(conn, mock_rss_feed("https://example.com/news/recent"))
        end
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      assert Repo.aggregate(News, :count) == 2

      updated_old_source = Repo.get(NewsSource, old_source.id)
      assert DateTime.diff(updated_old_source.last_fetched_at, old_source.last_fetched_at) > 0

      updated_recent_source = Repo.get(NewsSource, recent_source.id)

      assert updated_recent_source.last_fetched_at == recent_source.last_fetched_at

      updated_never_source = Repo.get(NewsSource, never_fetched_source.id)
      assert not is_nil(updated_never_source.last_fetched_at)
    end

    test "handles MetaScraper errors gracefully" do
      insert_news_source(%{
        name: "Test Source",
        url: "https://test2.example.com/rss",
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

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      feed = Repo.one(News)
      assert feed.content == "No description available"
    end

    test "parses valid published_at dates" do
      insert_news_source(%{
        name: "Test Source",
        url: "https://test3.example.com/rss",
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

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      feed = Repo.one(News)
      assert feed.published_at == DateTime.from_iso8601("2025-08-01T12:00:00Z") |> elem(1)
    end

    test "handles invalid published_at dates by using current time" do
      insert_news_source(%{
        name: "Test Source",
        url: "https://test4.example.com/rss",
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

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      feed = Repo.one(News)
      assert DateTime.diff(DateTime.utc_now(), feed.published_at) < 5
    end

    test "updates last_fetched_at for processed sources" do
      source =
        insert_news_source(%{
          name: "Test Source",
          url: "https://test5.example.com/rss",
          last_fetched_at: nil
        })

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed("https://example.com/news/5"))
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      updated_source = Repo.get(NewsSource, source.id)
      assert updated_source.last_fetched_at
      assert DateTime.diff(DateTime.utc_now(), updated_source.last_fetched_at) < 5
    end

    test "processes multiple feed sources concurrently" do
      Enum.map(1..3, fn i ->
        insert_news_source(%{
          name: "Source #{i}",
          url: "https://source#{i}.example.com/rss",
          last_fetched_at: nil
        })
      end)

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        case conn.request_path do
          "/rss" ->
            case conn.host do
              "source1.example.com" ->
                Req.Test.text(conn, mock_rss_feed("https://example.com/news/6"))

              "source2.example.com" ->
                Req.Test.text(conn, mock_rss_feed("https://example.com/news/7"))

              "source3.example.com" ->
                Req.Test.text(conn, mock_rss_feed("https://example.com/news/8"))
            end
        end
      end)

      Req.Test.stub(Bubble.Sources.HttpClient, fn conn ->
        Req.Test.html(
          conn,
          "<html><head><meta name=\"description\" content=\"Test description\"></head></html>"
        )
      end)

      job = %Oban.Job{args: %{}}
      assert :ok = FetchNewsCronJob.perform(job)

      assert Repo.aggregate(News, :count) == 3
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
end
