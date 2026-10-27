defmodule Bubble.News.FetchNewsCronJob do
  use Oban.Worker

  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.News.SourceOverride
  alias Bubble.Repo
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Repo.all(
        from(ns in NewsSource,
          where:
            is_nil(ns.last_fetched_at) or fragment("now() - ? > '23 hours'", ns.last_fetched_at)
        )
      )

    custom_url_map =
      SourceOverride.custom_urls_by_source_id()
      |> Repo.all()
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    url_to_source =
      sources
      |> Enum.flat_map(fn source ->
        effective_urls =
          [source.url | Map.get(custom_url_map, source.id, [])] |> Enum.uniq()

        Enum.map(effective_urls, fn url -> {url, source} end)
      end)
      |> Enum.uniq_by(fn {url, _} -> url end)
      |> Map.new()

    urls = Map.keys(url_to_source)
    Logger.info("Fetching new RSS feeds...", sources: urls)

    url_to_source
    |> Map.keys()
    |> RSSClient.fetch_feeds()
    |> Enum.each(fn
      {url, {:ok, news_items}} ->
        source = Map.get(url_to_source, url)

        if source do
          try do
            NewsProcessor.process_and_save_news(news_items, source)
          rescue
            e ->
              Logger.error("Failed to process news for #{url}: #{Exception.message(e)}")
          catch
            :exit, reason ->
              Logger.error("Unexpected exit processing news for #{url}: #{inspect(reason)}")
          end
        end

      {url, {:error, reason}} ->
        Logger.error("Failed to fetch RSS feed for #{url}: #{inspect(reason)}")
    end)

    :ok
  end
end
