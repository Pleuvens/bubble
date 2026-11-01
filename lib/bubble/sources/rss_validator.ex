defmodule Bubble.Sources.RSSValidator do
  import SweetXml

  alias Utils.HtmlEntities

  require Logger

  @type feed_item :: %{
          title: String.t(),
          url: String.t(),
          description: String.t(),
          content: String.t(),
          published_at: String.t(),
          video_id: String.t(),
          thumbnail_url: String.t()
        }

  @type parse_result :: {:ok, [feed_item()]} | {:error, atom()}

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

  defp safe_parse_xml(xml) do
    try do
      parsed = SweetXml.parse(String.trim(xml), dtd: :none)
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

  defp extract_items(parsed_xml) do
    try do
      items =
        parsed_xml
        |> xpath(
          ~x"//entry | //item"l,
          title: ~x"./title/text()"s,
          link_href: ~x"./link/@href"s,
          link_text: ~x"./link/text()"s,
          guid: ~x"./guid/text()"s,
          description: ~x"./description/text()"s,
          summary: ~x"./summary/text()"s,
          content: ~x"./content/text()"s,
          published: ~x"./published/text()"s,
          pub_date: ~x"./pubDate/text()"s,
          video_id: ~x"./*[local-name()='videoId']/text()"s,
          thumbnail_url: ~x".//*[local-name()='thumbnail']/@url"s
        )

      {:ok, items}
    catch
      :exit, reason ->
        Logger.warning("Failed to extract items from feed: #{inspect(reason)}")
        {:error, :item_extraction_failed}
    end
  end

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

  @url_keys [:link_href, :link_text, :guid]
  @description_keys [:description, :summary]
  @published_at_keys [:published, :pub_date]

  defp normalize_item(item) when is_map(item) do
    %{
      title: clean_string(Map.get(item, :title, "")),
      url: first_non_empty(item, @url_keys),
      description: first_non_empty(item, @description_keys),
      content: clean_string(Map.get(item, :content, "")),
      published_at: first_non_empty(item, @published_at_keys),
      video_id: clean_string(Map.get(item, :video_id, "")),
      thumbnail_url: clean_string(Map.get(item, :thumbnail_url, ""))
    }
  end

  defp first_non_empty(item, keys) do
    keys
    |> Enum.map(fn key -> clean_string(Map.get(item, key, "")) end)
    |> Enum.find("", fn value -> value != "" end)
  end

  defp valid_item?(%{title: title, url: url, description: desc}) do
    has_content = title != "" or desc != ""
    has_url = url != "" and valid_url?(url)

    has_content and has_url
  end

  defp valid_item?(_), do: false

  defp valid_url?(url) when is_binary(url) do
    uri = URI.parse(url)
    uri.scheme in ["http", "https"] and not is_nil(uri.host)
  rescue
    _ -> false
  end

  defp valid_url?(_), do: false

  defp clean_string(nil), do: ""
  defp clean_string(""), do: ""

  defp clean_string(str) when is_binary(str) do
    str
    |> String.trim()
    |> HtmlEntities.decode()
  end

  defp clean_string(_), do: ""
end
