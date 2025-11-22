defmodule Bubble.News.FetchSingleSourceJob do
  @moduledoc """
  Oban worker that fetches RSS feed for a single news source.
  Typically triggered when a new RSS source is added.
  """
  use Oban.Worker

  alias Bubble.News.NewsSource
  alias Bubble.Repo
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"news_source_id" => news_source_id}}) do
    source = Repo.get(NewsSource, news_source_id)

    if is_nil(source) do
      Logger.warning("NewsSource with id #{news_source_id} not found")
      {:error, :source_not_found}
    else
      fetch_source(source)
    end
  end

  defp fetch_source(source) do
    Logger.info("Fetching RSS feed for new source", source_url: source.url)

    case RSSClient.fetch_feed(source.url) do
      {:ok, news_items} ->
        NewsProcessor.process_and_save_news(news_items, source)

      {:error, reason} ->
        Logger.error("Failed to fetch RSS feed for #{source.url}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
