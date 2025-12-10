defmodule Bubble.Sources.RSSClientTest do
  use ExUnit.Case, async: true

  describe "fetch_feed/1" do
    test "fetches and parses a valid RSS feed" do
      url = "https://www.reddit.com/r/elixir/.rss"

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, mock_rss_feed())
      end)

      assert {:ok, [%{title: "Phoenix 1.8.0 released!"}]} =
               Bubble.Sources.RSSClient.fetch_feed(url)
    end

    test "returns error for invalid URL" do
      url = "https://invalid.url/rss"

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Plug.Conn.send_resp(conn, 404, "not found")
      end)

      assert {:error, :invalid_http_request} =
               Bubble.Sources.RSSClient.fetch_feed(url)
    end

    test "returns error when call fails" do
      url = "https://www.reddit.com/r/elixir/.rss"

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      assert {:error, :http_request_failed} =
               Bubble.Sources.RSSClient.fetch_feed(url)
    end

    test "returns error when parsing fails" do
      url = "https://www.reddit.com/r/elixir/.rss"

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        Req.Test.text(conn, "not a valid rss feed")
      end)

      assert {:error, :rss_parsing_failed} =
               Bubble.Sources.RSSClient.fetch_feed(url)
    end
  end

  describe "fetch_feeds/1" do
    test "fetches multiple RSS feeds concurrently" do
      urls = ["https://www.reddit.com/r/elixir/.rss", "https://www.reddit.com/r/phoenix/.rss"]

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        case conn.request_path do
          "/r/elixir/.rss" ->
            Req.Test.text(conn, mock_rss_feed())

          "/r/phoenix/.rss" ->
            Req.Test.text(conn, mock_rss_feed())
        end
      end)

      results = Bubble.Sources.RSSClient.fetch_feeds(urls)
      assert length(results) == 2
      assert Enum.all?(results, fn {_url, {:ok, _feed}} -> true end)
    end

    test "handles mixed success and failure results" do
      urls = ["https://www.reddit.com/r/elixir/.rss", "https://www.reddit.com/r/phoenix/.rss"]

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        case conn.request_path do
          "/r/elixir/.rss" ->
            Req.Test.text(conn, mock_rss_feed())

          "/r/phoenix/.rss" ->
            Req.Test.transport_error(conn, :timeout)
        end
      end)

      results = Bubble.Sources.RSSClient.fetch_feeds(urls)
      assert length(results) == 2

      # One should succeed
      assert Enum.any?(results, fn
        {_url, {:ok, _feed}} -> true
        _ -> false
      end)

      # One should fail
      assert Enum.any?(results, fn
        {_url, {:error, _reason}} -> true
        _ -> false
      end)
    end

    test "handles multiple failures without crashing" do
      urls = [
        "https://www.reddit.com/r/elixir/.rss",
        "https://www.reddit.com/r/phoenix/.rss",
        "https://www.reddit.com/r/erlang/.rss"
      ]

      Req.Test.stub(Bubble.Sources.RSSClient, fn conn ->
        case conn.request_path do
          "/r/elixir/.rss" ->
            Req.Test.text(conn, mock_rss_feed())

          "/r/phoenix/.rss" ->
            Req.Test.transport_error(conn, :timeout)

          "/r/erlang/.rss" ->
            Plug.Conn.send_resp(conn, 500, "Server Error")
        end
      end)

      # This should not crash despite multiple failures
      results = Bubble.Sources.RSSClient.fetch_feeds(urls)
      assert length(results) == 3

      # At least one should succeed
      assert Enum.any?(results, fn
        {_url, {:ok, _feed}} -> true
        _ -> false
      end)

      # At least two should fail
      error_count =
        Enum.count(results, fn
          {_url, {:error, _reason}} -> true
          _ -> false
        end)

      assert error_count >= 2
    end
  end

  defp mock_rss_feed do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed
    xmlns="http://www.w3.org/2005/Atom"
    xmlns:media="http://search.yahoo.com/mrss/">
    <category term="elixir" label="r/elixir"/>
    <updated>2025-08-15T11:37:29+00:00</updated>
    <icon>https://www.redditstatic.com/icon.png/</icon>
    <id>/r/elixir/.rss</id>
    <link rel="self" href="https://www.reddit.com/r/elixir/.rss" type="application/atom+xml" />
    <link rel="alternate" href="https://www.reddit.com/r/elixir/" type="text/html" />
    <logo>https://c.thumbs.redditmedia.com/XjRQi06trDPlQIfP.png</logo>
    <subtitle>Subreddit for the Elixir programming language, a dynamic, functional language designed for building scalable and maintainable applications. Learn more at https://elixir-lang.org.</subtitle>
    <title>The Elixir Programming Language</title>
    <entry>
    <author>
    <name>/u/vlatheimpaler</name>
    <uri>https://www.reddit.com/user/vlatheimpaler</uri>
    </author>
    <category term="elixir" label="r/elixir"/>
    <content type="html">&amp;#32; submitted by &amp;#32; &lt;a href=&quot;https://www.reddit.com/user/vlatheimpaler&quot;&gt; /u/vlatheimpaler &lt;/a&gt; &lt;br/&gt; &lt;span&gt;&lt;a href=&quot;https://www.phoenixframework.org/blog/phoenix-1-8-released&quot;&gt;[link]&lt;/a&gt;&lt;/span&gt; &amp;#32; &lt;span&gt;&lt;a href=&quot;https://www.reddit.com/r/elixir/comments/1mimde4/phoenix_180_released/&quot;&gt;[commentaires]&lt;/a&gt;&lt;/span&gt;</content>
    <id>t3_1mimde4</id>
    <link href="https://www.reddit.com/r/elixir/comments/1mimde4/phoenix_180_released/" />
    <updated>2025-08-05T21:44:41+00:00</updated>
    <published>2025-08-05T21:44:41+00:00</published>
    <title>Phoenix 1.8.0 released!</title>
    </entry>
    </feed>
    """
  end
end
