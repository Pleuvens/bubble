defmodule Bubble.Feeds.FetchNewCronJob do
  use Oban.Worker

  alias Bubble.Sources.RssClient

  require Logger

  @impl true
  def perform(%Oban.Job{}) do
    Logger.info("Fetching new RSS feeds...")
    RssClient.fetch_feeds([])
    :ok
  end
end
