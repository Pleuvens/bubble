defmodule Bubble.Sources.RSSValidator do
  @moduledoc """
  Validates and parses RSS/Atom feeds with comprehensive error handling.

  This module provides robust parsing for both RSS 2.0 and Atom feeds,
  with validation to ensure feed items contain required fields and are
  properly formatted.
  """

  import SweetXml

  require Logger

  @type feed_item :: %{
          title: String.t(),
          url: String.t(),
          description: String.t(),
          content: String.t(),
          published_at: String.t()
        }

  @type parse_result :: {:ok, [feed_item()]} | {:error, atom()}

  @doc """
  Parses and validates an RSS or Atom feed from XML content.

  Returns `{:ok, items}` if parsing succeeds, where items is a list of maps
  containing feed item data. Returns `{:error, reason}` if parsing fails.

  ## Examples

      iex> xml = ~s[<?xml version="1.0"?><rss><channel><item><title>Test</title></item></channel></rss>]
      iex> Bubble.Sources.RSSValidator.parse_and_validate(xml)
      {:ok, [%{title: "Test", url: "", description: "", content: "", published_at: ""}]}

  """
  @spec parse_and_validate(String.t()) :: parse_result()
  def parse_and_validate(xml) when is_binary(xml) do
    with {:ok, parsed_xml} <- safe_parse_xml(xml),
         {:ok, items} <- extract_items(parsed_xml),
         {:ok, validated_items} <- validate_items(items) do
      {:ok, validated_items}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Safely parse XML with error handling
  defp safe_parse_xml(xml) do
    try do
      # Trim leading/trailing whitespace before parsing
      cleaned_xml = String.trim(xml)
      parsed = SweetXml.parse(cleaned_xml, dtd: :none)
      {:ok, parsed}
    catch
      :exit, {:fatal, error} ->
        Logger.warning("XML parsing failed: #{inspect(error)}")
        {:error, :invalid_xml}

      :exit, reason ->
        Logger.warning("XML parsing failed: #{inspect(reason)}")
        {:error, :invalid_xml}
    end
  end

  # Extract items from both RSS and Atom feeds
  defp extract_items(parsed_xml) do
    try do
      items =
        parsed_xml
        |> xpath(
          ~x"//entry | //item"l,
          title: ~x"./title/text()"s,
          url: ~x"./link/@href | ./link/text() | ./guid/text()"s,
          description: ~x"./description/text() | ./summary/text()"s,
          content: ~x"./content/text()"s,
          published_at: ~x"./published/text() | ./pubDate/text()"s
        )

      {:ok, items}
    catch
      :exit, reason ->
        Logger.warning("Failed to extract items from feed: #{inspect(reason)}")
        {:error, :item_extraction_failed}
    end
  end

  # Validate extracted items
  defp validate_items(items) when is_list(items) do
    validated =
      items
      |> Enum.map(&normalize_item/1)
      |> Enum.filter(&valid_item?/1)

    if Enum.empty?(validated) do
      {:error, :no_valid_items}
    else
      {:ok, validated}
    end
  end

  # Normalize an item to ensure all fields are present
  defp normalize_item(item) when is_map(item) do
    %{
      title: clean_string(Map.get(item, :title, "")),
      url: clean_string(Map.get(item, :url, "")),
      description: clean_string(Map.get(item, :description, "")),
      content: clean_string(Map.get(item, :content, "")),
      published_at: clean_string(Map.get(item, :published_at, ""))
    }
  end

  # Check if an item is valid (has at least title or description, and a URL)
  defp valid_item?(%{title: title, url: url, description: desc}) do
    has_content = title != "" or desc != ""
    has_url = url != "" and valid_url?(url)

    has_content and has_url
  end

  defp valid_item?(_), do: false

  # Validate URL format
  defp valid_url?(url) when is_binary(url) do
    uri = URI.parse(url)
    uri.scheme in ["http", "https"] and not is_nil(uri.host)
  rescue
    _ -> false
  end

  defp valid_url?(_), do: false

  # Clean and trim strings
  defp clean_string(nil), do: ""
  defp clean_string(""), do: ""

  defp clean_string(str) when is_binary(str) do
    str
    |> String.trim()
    |> decode_html_entities()
  end

  defp clean_string(_), do: ""

  # Basic HTML entity decoding for common entities
  defp decode_html_entities(str) do
    str
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#32;", " ")
    |> String.replace("&apos;", "'")
  end

  @doc """
  Checks if the given XML string appears to be a valid RSS or Atom feed.

  Returns `true` if the XML contains RSS or Atom feed markers, `false` otherwise.

  ## Examples

      iex> Bubble.Sources.RSSValidator.valid_feed_format?("<rss version=\\"2.0\\"></rss>")
      true

      iex> Bubble.Sources.RSSValidator.valid_feed_format?("<html></html>")
      false

  """
  @spec valid_feed_format?(String.t()) :: boolean()
  def valid_feed_format?(xml) when is_binary(xml) do
    String.contains?(xml, ["<rss", "<feed", "<atom", "<channel"]) and
      String.contains?(xml, ["</rss>", "</feed>", "</atom>", "</channel>"])
  end

  def valid_feed_format?(_), do: false
end
