defmodule Bubble.Feeds.FetchNewsCronJob do
  use Oban.Worker

  import Ecto.Query

  alias Bubble.Feeds.Feed
  alias Bubble.Feeds.FeedSource
  alias Bubble.Repo
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Repo.all(
        from(fs in FeedSource,
          where:
            is_nil(fs.last_fetched_at) or fragment("now() - ? < '1 day'", fs.last_fetched_at),
          select: fs.url
        )
      )

    Logger.info("Fetching new RSS feeds...", sources: sources)

    fetched_news = RSSClient.fetch_feeds(sources)

    news_to_insert =
      Enum.flat_map(fetched_news, fn {_source_url, {:ok, news_items}} ->
        news_items
      end)
      |> Enum.map(fn news ->
        %{
          news
          | published_at: DateTime.from_iso8601(news.published_at) |> elem(1),
            content: HtmlSanitizeEx.strip_tags(news.content)
        }
      end)
      |> dbg()

    Repo.insert_all(Feed, news_to_insert)

    Repo.update_all(
      from(fs in FeedSource,
        where: is_nil(fs.last_fetched_at) or fragment("now() - ? < '1 day'", fs.last_fetched_at)
      ),
      set: [last_fetched_at: DateTime.utc_now()]
    )

    :ok
  end
end
