defmodule Bubble.Sources.RSSClient do
  @moduledoc """
  A simple module to fetch and parse RSS feeds using Req and Quinn.
  """

  import SweetXml

  require Logger

  @doc """
  Fetches and parses an RSS feed from the given URL.
  """
  def fetch_feed(url) do
    get_params =
      Keyword.merge([url: url], Application.get_env(:bubble, :rss_client_req_options, []))

    with {:ok, %{status: 200, body: body}} <- Req.get(get_params),
         parsed_feed when is_list(parsed_feed) <- parse_rss(body) do
      {:ok, parsed_feed}
    else
      {:ok, %{status: status}} ->
        Logger.warning("Failed to fetch RSS feed: HTTP status #{status} for URL #{url}")
        {:error, :invalid_http_request}

      {:error, reason} ->
        Logger.warning("Failed to fetch RSS feed: #{inspect(reason)} for URL #{url}")
        {:error, :http_request_failed}

      other ->
        Logger.warning("Failed to parse RSS feed: #{inspect(other)} for URL #{url}")
        {:error, :rss_parsing_failed}
    end
  end

  @doc """
  Fetches and parses multiple RSS feeds concurrently.
  """
  def fetch_feeds(urls) when is_list(urls) do
    urls
    |> Task.async_stream(&{&1, fetch_feed(&1)}, timeout: 10_000, max_concurrency: 5)
    |> Enum.map(fn {:ok, result} -> result end)
  end

  defp parse_rss(xml) do
    xml
    |> SweetXml.parse(dtd: :none)
    |> xpath(
      ~x"//entry"l,
      title: ~x"./title/text()"s,
      link: ~x"./link/@href"s,
      category: ~x"./category/text()"s,
      content: ~x"./content/text()"s
    )
  catch
    :exit, {:fatal, _} ->
      :rss_parsing_failed
  end
end
