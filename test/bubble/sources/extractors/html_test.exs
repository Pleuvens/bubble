defmodule Bubble.Sources.Extractors.HtmlTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.Extractors.Html

  describe "extract_description/1" do
    test "extracts the standard meta description" do
      html = ~s(<meta name="description" content="A standard description">)

      assert {:ok, "A standard description"} = Html.extract_description(html)
    end

    test "extracts the description whatever the attribute order" do
      html = ~s(<meta charset="utf-8" content="Reversed standard description" name="description">)

      assert {:ok, "Reversed standard description"} = Html.extract_description(html)
    end

    test "ignores other meta tags" do
      html = ~s(<meta name="keywords" content="news, elixir, phoenix">)

      assert {:error, :not_found} = Html.extract_description(html)
    end
  end

  describe "extract_title/1" do
    test "extracts the title element" do
      html = "<html><head><title>The Page Title</title></head><body>Hello</body></html>"

      assert {:ok, "The Page Title"} = Html.extract_title(html)
    end

    test "extracts the title of a tag carrying attributes" do
      html = ~s(<title data-test="x">Another Page Title</title>)

      assert {:ok, "Another Page Title"} = Html.extract_title(html)
    end

    test "returns error when there is no title" do
      html = "<html><head></head><body>Hello</body></html>"

      assert {:error, :not_found} = Html.extract_title(html)
    end
  end
end
