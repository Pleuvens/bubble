defmodule Bubble.Sources.RSSClient do
  alias Bubble.Sources.RSSValidator
  alias Utils.FeedUrl
  alias Utils.FetchGuard

  require Logger

  @parsing_failures [:invalid_xml, :item_extraction_failed, :no_valid_items]

  def fetch_feed(url) do
    with :ok <- ensure_fetchable_url(url),
         {:ok, %{status: 200, body: body}} <- url |> build_request() |> Req.request(),
         {:ok, parsed_feed} <- RSSValidator.parse_and_validate(body) do
      {:ok, parsed_feed}
    else
      failure -> handle_failure(failure, url)
    end
  end

  def fetch_feeds(urls) when is_list(urls) do
    urls
    |> Task.async_stream(&{&1, fetch_feed(&1)},
      timeout: 10_000,
      max_concurrency: 5,
      on_timeout: :kill_task
    )
    |> Enum.map(fn
      {:ok, result} ->
        result

      {:exit, reason} ->
        Logger.warning("RSS feed fetch task exited: #{inspect(reason)}")
        {nil, {:error, :task_timeout}}
    end)
  end

  defp handle_failure({:error, :malformed_url}, url) do
    Logger.warning("Skipping RSS feed with malformed URL: #{inspect(url)}")
    {:error, :malformed_url}
  end

  defp handle_failure({:error, %ReqSSRF.BlockedError{} = error}, _url) do
    Logger.warning("Blocked RSS feed fetch to an internal address: #{URI.to_string(error.url)}")
    {:error, :blocked_url}
  end

  defp handle_failure({:ok, %{status: status}}, url) do
    Logger.warning("Failed to fetch RSS feed: HTTP status #{status} for URL #{url}")
    {:error, :invalid_http_request}
  end

  defp handle_failure({:error, reason}, url) when reason in @parsing_failures do
    Logger.warning("Failed to parse RSS feed: #{reason} for URL #{url}")
    {:error, :rss_parsing_failed}
  end

  defp handle_failure({:error, reason}, url) do
    Logger.warning("Failed to fetch RSS feed: #{inspect(reason)} for URL #{url}")
    {:error, :http_request_failed}
  end

  defp build_request(url) do
    url
    |> request_options()
    |> Req.new()
    |> FetchGuard.attach()
  end

  defp request_options(url) do
    Keyword.merge([url: url], Application.get_env(:bubble, :rss_client_req_options, []))
  end

  defp ensure_fetchable_url(url) do
    if FeedUrl.fetchable?(url), do: :ok, else: {:error, :malformed_url}
  end
end
