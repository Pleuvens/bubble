defmodule Bubble.Sources.Extractors.UtilsTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.Extractors.Utils

  describe "clean_text/1" do
    test "trims whitespace" do
      assert "Hello World" = Utils.clean_text("  Hello World  ")
    end

    test "decodes HTML entities" do
      assert "Hello & goodbye" = Utils.clean_text("Hello &amp; goodbye")
      assert "It's working" = Utils.clean_text("It&#39;s working")
    end

    test "returns nil for empty or short text" do
      assert nil == Utils.clean_text("")
      assert nil == Utils.clean_text("   ")
      assert nil == Utils.clean_text("Hi")
      assert nil == Utils.clean_text("Short")
    end

    test "returns nil for nil input" do
      assert nil == Utils.clean_text(nil)
    end

    test "accepts text longer than 10 characters" do
      assert "This is long enough" = Utils.clean_text("This is long enough")
    end
  end

  describe "decode_html_entities/1" do
    test "decodes common HTML entities" do
      assert "Hello & World" = Utils.decode_html_entities("Hello &amp; World")
      assert "<div>" = Utils.decode_html_entities("&lt;div&gt;")
      assert ~s("quoted") = Utils.decode_html_entities("&quot;quoted&quot;")
      assert "It's great" = Utils.decode_html_entities("It&#39;s great")
    end

    test "handles multiple entities in one string" do
      input = "Hello &amp; goodbye &lt;world&gt;"
      expected = "Hello & goodbye <world>"
      assert expected == Utils.decode_html_entities(input)
    end
  end

  describe "extract_meta_content/2" do
    test "extracts content using first matching pattern" do
      html = ~s(<meta name="description" content="Test Description">)
      patterns = [~r/<meta\s+name="description"\s+content="([^"]+)"/i]

      assert "Test Description" = Utils.extract_meta_content(html, patterns)
    end

    test "tries multiple patterns in order" do
      html = ~s(<meta content="Found it here for testing" property="og:description">)

      patterns = [
        ~r/<meta\s+property="og:description"\s+content="([^"]+)"/i,
        ~r/<meta\s+content="([^"]+)"\s+property="og:description"/i
      ]

      assert "Found it here for testing" = Utils.extract_meta_content(html, patterns)
    end

    test "returns nil when no pattern matches" do
      html = ~s(<meta name="keywords" content="test">)
      patterns = [~r/<meta\s+name="description"\s+content="([^"]+)"/i]

      assert nil == Utils.extract_meta_content(html, patterns)
    end

    test "cleans extracted text" do
      html = ~s(<meta name="description" content="  Clean &amp; trim  ">)
      patterns = [~r/<meta\s+name="description"\s+content="([^"]+)"/i]

      assert "Clean & trim" = Utils.extract_meta_content(html, patterns)
    end
  end
end
