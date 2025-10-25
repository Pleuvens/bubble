defmodule Bubble.Sources.Extractors.OpenGraphTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.Extractors.{Extractor, OpenGraph}

  describe "extract_description/2" do
    test "extracts OpenGraph description with property then content" do
      html = ~s(<meta property="og:description" content="This is a test description">)
      extractor = OpenGraph.new()

      assert {:ok, "This is a test description"} = Extractor.extract_description(extractor, html)
    end

    test "extracts OpenGraph description with content then property" do
      html = ~s(<meta content="Another test description" property="og:description">)
      extractor = OpenGraph.new()

      assert {:ok, "Another test description"} = Extractor.extract_description(extractor, html)
    end

    test "returns error when description not found" do
      html = ~s(<meta property="og:title" content="Just a title">)
      extractor = OpenGraph.new()

      assert {:error, :not_found} = Extractor.extract_description(extractor, html)
    end

    test "trims and cleans description" do
      html = ~s(<meta property="og:description" content="  Trimmed &amp; cleaned  ">)
      extractor = OpenGraph.new()

      assert {:ok, "Trimmed & cleaned"} = Extractor.extract_description(extractor, html)
    end
  end

  describe "extract_title/2" do
    test "extracts OpenGraph title" do
      html = ~s(<meta property="og:title" content="Test Title Here">)
      extractor = OpenGraph.new()

      assert {:ok, "Test Title Here"} = Extractor.extract_title(extractor, html)
    end

    test "returns error when title not found" do
      html = ~s(<meta property="og:description" content="Just a description">)
      extractor = OpenGraph.new()

      assert {:error, :not_found} = Extractor.extract_title(extractor, html)
    end
  end
end
