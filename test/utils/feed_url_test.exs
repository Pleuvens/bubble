defmodule Utils.FeedUrlTest do
  use ExUnit.Case, async: true

  alias Utils.FeedUrl

  describe "fetchable?/1" do
    test "accepts http and https URLs with a domain" do
      assert FeedUrl.fetchable?("https://bsky.app/rss")
      assert FeedUrl.fetchable?("http://example.com")
    end

    test "rejects a URL whose separator is backslashes" do
      refute FeedUrl.fetchable?("https:\\\\bsky.app")
    end

    test "rejects a URL with no scheme, no host, or no value at all" do
      refute FeedUrl.fetchable?("bsky.app")
      refute FeedUrl.fetchable?("https://")
      refute FeedUrl.fetchable?("ftp://example.com")
      refute FeedUrl.fetchable?("")
      refute FeedUrl.fetchable?(nil)
    end
  end
end
