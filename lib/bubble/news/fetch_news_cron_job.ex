defmodule Bubble.News.FetchNewsCronJob do
  use Oban.Worker

  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.Repo
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Repo.all(
        from(ns in NewsSource,
          where: is_nil(ns.last_fetched_at) or fragment("now() - ? > '1 day'", ns.last_fetched_at)
        )
      )

    source_urls = Enum.map(sources, & &1.url)

    Logger.info("Fetching new RSS feeds...", sources: source_urls)

    fetched_news = RSSClient.fetch_feeds(source_urls)

    NewsProcessor.process_and_save_news_batch(sources, fetched_news)

    :ok
  end
end
