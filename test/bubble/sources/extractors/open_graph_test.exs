defmodule Bubble.Sources.Extractors.OpenGraphTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.Extractors.OpenGraph

  describe "extract_description/1" do
    test "extracts OpenGraph description with property then content" do
      html = ~s(<meta property="og:description" content="This is a test description">)

      assert {:ok, "This is a test description"} = OpenGraph.extract_description(html)
    end

    test "extracts OpenGraph description with content then property" do
      html = ~s(<meta content="Another test description" property="og:description">)

      assert {:ok, "Another test description"} = OpenGraph.extract_description(html)
    end

    test "returns error when description not found" do
      html = ~s(<meta property="og:title" content="Just a title">)

      assert {:error, :not_found} = OpenGraph.extract_description(html)
    end

    test "trims and cleans description" do
      html = ~s(<meta property="og:description" content="  Trimmed &amp; cleaned  ">)

      assert {:ok, "Trimmed & cleaned"} = OpenGraph.extract_description(html)
    end

    test "extracts description when other attributes sit between property and content" do
      html =
        ~s(<meta property="og:description" name="description" content="Order should not matter">)

      assert {:ok, "Order should not matter"} = OpenGraph.extract_description(html)
    end

    test "extracts description from single-quoted attributes" do
      html = ~s(<meta property='og:description' content='Single quoted description'>)

      assert {:ok, "Single quoted description"} = OpenGraph.extract_description(html)
    end

    test "extracts description spread over several lines" do
      html = """
      <meta
        property="og:description"
        content="Multiline attributes still work">
      """

      assert {:ok, "Multiline attributes still work"} = OpenGraph.extract_description(html)
    end

    test "returns error for an empty document" do
      assert {:error, :not_found} = OpenGraph.extract_description("")
    end
  end

  describe "extract_title/1" do
    test "extracts OpenGraph title" do
      html = ~s(<meta property="og:title" content="Test Title Here">)

      assert {:ok, "Test Title Here"} = OpenGraph.extract_title(html)
    end

    test "returns error when title not found" do
      html = ~s(<meta property="og:description" content="Just a description">)

      assert {:error, :not_found} = OpenGraph.extract_title(html)
    end

    test "extracts title when content comes before property" do
      html = ~s(<meta content="Reversed Title Here" property="og:title">)

      assert {:ok, "Reversed Title Here"} = OpenGraph.extract_title(html)
    end
  end
end
