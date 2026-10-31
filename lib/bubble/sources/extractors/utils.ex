defmodule Bubble.Sources.Extractors.Utils do
  @moduledoc """
  Utility functions shared across different extractors.

  Provides common functionality for:
  - Text cleaning and normalization
  - HTML entity decoding
  - Meta tag and element selection with Floki
  """

  @type locator :: {:meta_content, String.t()} | {:element_text, String.t()}

  @spec extract_content(String.t(), locator()) :: String.t() | nil
  def extract_content(html, locator) when is_binary(html) do
    case Floki.parse_document(html) do
      {:ok, document} -> document |> read_locator(locator) |> clean_text()
      {:error, _reason} -> nil
    end
  end

  defp read_locator(document, {:meta_content, selector}) do
    document
    |> Floki.attribute(selector, "content")
    |> List.first()
  end

  defp read_locator(document, {:element_text, selector}) do
    document
    |> Floki.find(selector)
    |> Floki.text()
  end

  @doc """
  Cleans and validates text content.

  - Trims whitespace
  - Decodes HTML entities
  - Ensures minimum length (> 10 characters)
  - Returns `nil` for invalid text

  ## Examples

      iex> Utils.clean_text("  Hello &amp; World  ")
      "Hello & World"

      iex> Utils.clean_text("Hi")
      nil

      iex> Utils.clean_text(nil)
      nil
  """
  @spec clean_text(String.t() | nil) :: String.t() | nil
  def clean_text(nil), do: nil
  def clean_text(""), do: nil

  def clean_text(text) when is_binary(text) do
    cleaned =
      text
      |> String.trim()
      |> decode_html_entities()

    if cleaned != "" and String.length(cleaned) > 10 do
      cleaned
    else
      nil
    end
  end

  def clean_text(_), do: nil

  @doc """
  Decodes common HTML entities to their character equivalents.

  ## Examples

      iex> Utils.decode_html_entities("Hello &amp; goodbye")
      "Hello & goodbye"

      iex> Utils.decode_html_entities("It&#39;s working")
      "It's working"
  """
  @spec decode_html_entities(String.t()) :: String.t()
  def decode_html_entities(str) when is_binary(str) do
    str
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#32;", " ")
    |> String.replace("&#39;", "'")
    |> String.replace("&apos;", "'")
    |> String.replace("&nbsp;", " ")
    |> String.replace("&#8217;", "'")
    |> String.replace("&#8216;", "'")
    |> String.replace("&#8220;", ~s("))
    |> String.replace("&#8221;", ~s("))
  end
end
