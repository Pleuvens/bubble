defmodule Bubble.News.FetchNewsCronJob do
  use Oban.Worker

  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.News.SourceOverride
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    url_to_source =
      subscribed_sources_due_for_fetch()
      |> Repo.all()
      |> build_url_to_source()

    urls = Map.keys(url_to_source)
    Logger.info("Fetching new RSS feeds...", sources: urls)

    urls
    |> RSSClient.fetch_feeds()
    |> Enum.each(&process_feed_result(&1, url_to_source))

    :ok
  end

  defp build_url_to_source(sources) do
    custom_urls = custom_urls_by_source_id()

    sources
    |> Enum.flat_map(fn source ->
      [source.url | Map.get(custom_urls, source.id, [])]
      |> Enum.uniq()
      |> Enum.map(fn url -> {url, source} end)
    end)
    |> Enum.uniq_by(fn {url, _source} -> url end)
    |> Map.new()
  end

  defp custom_urls_by_source_id do
    SourceOverride.custom_urls_by_source_id()
    |> Repo.all()
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp process_feed_result({url, {:ok, news_items}}, url_to_source) do
    process_news(news_items, Map.fetch!(url_to_source, url), url)
  end

  defp process_feed_result({url, {:error, reason}}, _url_to_source) do
    Logger.error("Failed to fetch RSS feed for #{url}: #{inspect(reason)}")
  end

  defp process_news(news_items, source, url) do
    NewsProcessor.process_and_save_news(news_items, source)
  rescue
    e ->
      Logger.error("Failed to process news for #{url}: #{Exception.message(e)}")
  catch
    :exit, reason ->
      Logger.error("Unexpected exit processing news for #{url}: #{inspect(reason)}")
  end

  defp subscribed_sources_due_for_fetch do
    from(ns in NewsSource.due_for_fetch(),
      join: uns in UserNewsSource,
      on: uns.news_source_id == ns.id,
      distinct: true
    )
  end
end
