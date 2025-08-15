defmodule Bubble.Feeds.FetchNewCronJob do
  use Oban.Worker

  import Ecto.Query

  alias Bubble.Feeds.FeedSource
  alias Bubble.Repo
  alias Bubble.Sources.RssClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Repo.all(
        from(fs in FeedSource,
          where: fragment("now() - ? < '1 day'", fs.last_fetched_at),
          select: fs.url
        )
      )

    Logger.info("Fetching new RSS feeds...", sources: sources)
    RssClient.fetch_feeds(sources)

    Repo.update_all(
      from(fs in FeedSource,
        where: fragment("now() - ? < '1 day'", fs.last_fetched_at)
      ),
      set: [last_fetched_at: DateTime.utc_now()]
    )

    :ok
  end
end
