defmodule Bubble.Sources.Extractors.TwitterCardTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.Extractors.TwitterCard

  describe "extract_description/1" do
    test "extracts the twitter description" do
      html = ~s(<meta name="twitter:description" content="A twitter description">)

      assert {:ok, "A twitter description"} = TwitterCard.extract_description(html)
    end

    test "extracts the description whatever the attribute order" do
      html = ~s(<meta content="Reversed twitter description" name="twitter:description">)

      assert {:ok, "Reversed twitter description"} = TwitterCard.extract_description(html)
    end

    test "ignores the open graph description" do
      html = ~s(<meta property="og:description" content="An open graph description">)

      assert {:error, :not_found} = TwitterCard.extract_description(html)
    end
  end

  describe "extract_title/1" do
    test "extracts the twitter title" do
      html = ~s(<meta name="twitter:title" content="A twitter title">)

      assert {:ok, "A twitter title"} = TwitterCard.extract_title(html)
    end

    test "returns error when the title is missing" do
      html = ~s(<meta name="twitter:description" content="Only a description here">)

      assert {:error, :not_found} = TwitterCard.extract_title(html)
    end
  end
end
