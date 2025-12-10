defmodule Bubble.Sources.RSSClient do
  @moduledoc """
  A simple module to fetch RSS feeds using Req.

  Parsing and validation is delegated to `Bubble.Sources.RSSValidator`.
  """

  alias Bubble.Sources.RSSValidator

  require Logger

  @doc """
  Fetches and parses an RSS feed from the given URL.
  """
  def fetch_feed(url) do
    get_params =
      Keyword.merge([url: url], Application.get_env(:bubble, :rss_client_req_options, []))

    with {:ok, %{status: 200, body: body}} <- Req.get(get_params),
         {:ok, parsed_feed} <- RSSValidator.parse_and_validate(body) do
      {:ok, parsed_feed}
    else
      {:ok, %{status: status}} ->
        Logger.warning("Failed to fetch RSS feed: HTTP status #{status} for URL #{url}")
        {:error, :invalid_http_request}

      {:error, reason} when reason in [:invalid_xml, :item_extraction_failed, :no_valid_items] ->
        Logger.warning("Failed to parse RSS feed: #{reason} for URL #{url}")
        {:error, :rss_parsing_failed}

      {:error, reason} ->
        Logger.warning("Failed to fetch RSS feed: #{inspect(reason)} for URL #{url}")
        {:error, :http_request_failed}
    end
  end

  @doc """
  Fetches and parses multiple RSS feeds concurrently.
  """
  def fetch_feeds(urls) when is_list(urls) do
    urls
    |> Task.async_stream(&{&1, fetch_feed(&1)}, timeout: 10_000, max_concurrency: 5)
    |> Enum.map(fn
      {:ok, result} ->
        result

      {:exit, reason} ->
        Logger.warning("RSS feed fetch task exited: #{inspect(reason)}")
        {nil, {:error, :task_timeout}}
    end)
  end
end
