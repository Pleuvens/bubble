defmodule Bubble.Sources.RSSValidatorTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.RSSValidator

  describe "parse_and_validate/1" do
    test "parses valid Atom feed" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Test Feed</title>
      <entry>
      <title>Entry 1</title>
      <link href="https://example.com/entry1" />
      <published>2025-08-05T21:44:41+00:00</published>
      <summary>This is entry 1</summary>
      <content>Full content of entry 1</content>
      </entry>
      </feed>
      """

      assert {:ok, [item]} = RSSValidator.parse_and_validate(xml)
      assert item.title == "Entry 1"
      assert item.url == "https://example.com/entry1"
      assert item.description == "This is entry 1"
      assert item.content == "Full content of entry 1"
      assert item.published_at == "2025-08-05T21:44:41+00:00"
    end

    test "parses valid RSS 2.0 feed" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
      <channel>
      <title>Test Channel</title>
      <item>
      <title>Item 1</title>
      <link>https://example.com/item1</link>
      <pubDate>Mon, 05 Aug 2025 21:44:41 +0000</pubDate>
      <description>This is item 1</description>
      </item>
      </channel>
      </rss>
      """

      assert {:ok, [item]} = RSSValidator.parse_and_validate(xml)
      assert item.title == "Item 1"
      assert item.url == "https://example.com/item1"
      assert item.description == "This is item 1"
    end

    test "handles multiple items" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <title>Entry 1</title>
      <link href="https://example.com/1" />
      </entry>
      <entry>
      <title>Entry 2</title>
      <link href="https://example.com/2" />
      </entry>
      <entry>
      <title>Entry 3</title>
      <link href="https://example.com/3" />
      </entry>
      </feed>
      """

      assert {:ok, items} = RSSValidator.parse_and_validate(xml)
      assert length(items) == 3
      assert Enum.at(items, 0).title == "Entry 1"
      assert Enum.at(items, 1).title == "Entry 2"
      assert Enum.at(items, 2).title == "Entry 3"
    end

    test "cleans HTML entities from content" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <title>Entry&#32;with&#32;&amp;amp;&amp;lt;entities&amp;gt;</title>
      <link href="https://example.com/1" />
      <content>&quot;Quoted&quot; &amp; &apos;apostrophe&apos;</content>
      </entry>
      </feed>
      """

      assert {:ok, [item]} = RSSValidator.parse_and_validate(xml)
      assert item.title == "Entry with &<entities>"
      assert item.content == "\"Quoted\" & 'apostrophe'"
    end

    test "filters out items without valid URLs" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <title>Valid Entry</title>
      <link href="https://example.com/valid" />
      </entry>
      <entry>
      <title>Invalid Entry</title>
      <link href="not-a-url" />
      </entry>
      <entry>
      <title>Missing URL Entry</title>
      </entry>
      </feed>
      """

      assert {:ok, items} = RSSValidator.parse_and_validate(xml)
      assert length(items) == 1
      assert hd(items).title == "Valid Entry"
    end

    test "filters out items without title or description" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <title>Valid Entry</title>
      <link href="https://example.com/1" />
      </entry>
      <entry>
      <link href="https://example.com/2" />
      </entry>
      </feed>
      """

      assert {:ok, items} = RSSValidator.parse_and_validate(xml)
      assert length(items) == 1
      assert hd(items).title == "Valid Entry"
    end

    test "returns error for invalid XML" do
      xml = "This is not XML at all"

      assert {:error, :invalid_xml} = RSSValidator.parse_and_validate(xml)
    end

    test "returns error for malformed XML" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed>
      <entry>
      <title>Unclosed entry
      </entry
      </feed>
      """

      assert {:error, :invalid_xml} = RSSValidator.parse_and_validate(xml)
    end

    test "returns error when no valid items found" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <link href="invalid-url" />
      </entry>
      </feed>
      """

      assert {:error, :no_valid_items} = RSSValidator.parse_and_validate(xml)
    end

    test "handles feed with guid as link source" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
      <channel>
      <item>
      <title>Item with GUID</title>
      <guid>https://example.com/item-guid</guid>
      <description>Item using GUID as URL</description>
      </item>
      </channel>
      </rss>
      """

      assert {:ok, [item]} = RSSValidator.parse_and_validate(xml)
      assert item.url == "https://example.com/item-guid"
    end

    test "trims whitespace from fields" do
      xml = ~s"""
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
      <title>  Title with spaces  </title>
      <link href="  https://example.com/1  " />
      <summary>  Description with spaces  </summary>
      </entry>
      </feed>
      """

      assert {:ok, [item]} = RSSValidator.parse_and_validate(xml)
      assert item.title == "Title with spaces"
      assert item.url == "https://example.com/1"
      assert item.description == "Description with spaces"
    end
  end

  describe "valid_feed_format?/1" do
    test "returns true for RSS feed" do
      xml = ~s"""
      <?xml version="1.0"?>
      <rss version="2.0">
      <channel>
      <title>Test</title>
      </channel>
      </rss>
      """

      assert RSSValidator.valid_feed_format?(xml)
    end

    test "returns true for Atom feed" do
      xml = ~s"""
      <?xml version="1.0"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Test</title>
      </feed>
      """

      assert RSSValidator.valid_feed_format?(xml)
    end

    test "returns false for HTML" do
      html = """
      <!DOCTYPE html>
      <html>
      <head><title>Not a feed</title></head>
      <body>Content</body>
      </html>
      """

      refute RSSValidator.valid_feed_format?(html)
    end

    test "returns false for plain text" do
      refute RSSValidator.valid_feed_format?("Just some text")
    end

    test "returns false for non-string input" do
      refute RSSValidator.valid_feed_format?(123)
      refute RSSValidator.valid_feed_format?(nil)
    end
  end
end
