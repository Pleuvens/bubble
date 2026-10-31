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

  describe "extract_content/2" do
    test "reads the content attribute of a matching meta tag" do
      html = ~s(<meta name="description" content="Test Description">)

      assert "Test Description" =
               Utils.extract_content(html, {:meta_content, ~s(meta[name="description"])})
    end

    test "ignores attribute order" do
      html = ~s(<meta content="Found it here for testing" property="og:description">)

      assert "Found it here for testing" =
               Utils.extract_content(html, {:meta_content, ~s(meta[property="og:description"])})
    end

    test "returns nil when nothing matches the locator" do
      html = ~s(<meta name="keywords" content="test">)

      assert nil == Utils.extract_content(html, {:meta_content, ~s(meta[name="description"])})
    end

    test "cleans the extracted text" do
      html = ~s(<meta name="description" content="  Clean &amp; trim  ">)

      assert "Clean & trim" =
               Utils.extract_content(html, {:meta_content, ~s(meta[name="description"])})
    end

    test "reads the text of a matching element" do
      html = "<html><head><title>A Page Title</title></head><body>body</body></html>"

      assert "A Page Title" = Utils.extract_content(html, {:element_text, "title"})
    end
  end
end
