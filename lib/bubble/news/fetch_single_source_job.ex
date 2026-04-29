defmodule Bubble.News.FetchSingleSourceJob do
  @moduledoc """
  Oban worker that fetches RSS feed for a single news source.
  Typically triggered when a new RSS source is added or manually refreshed.

  Accepts an optional `user_id` arg. When provided, the user's `custom_url`
  on their subscription is always preferred over the shared source URL.
  """
  use Oban.Worker

  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo
  alias Bubble.Sources.NewsProcessor
  alias Bubble.Sources.RSSClient

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"news_source_id" => news_source_id} = args}) do
    source = Repo.get(NewsSource, news_source_id)

    if is_nil(source) do
      Logger.warning("NewsSource with id #{news_source_id} not found")
      {:error, :source_not_found}
    else
      url = effective_url(source, Map.get(args, "user_id"))
      fetch_source(source, url)
    end
  end

  defp effective_url(source, nil), do: source.url

  defp effective_url(source, user_id) do
    case Repo.get_by(UserNewsSource, user_id: user_id, news_source_id: source.id) do
      %UserNewsSource{custom_url: custom_url} when is_binary(custom_url) and custom_url != "" ->
        custom_url

      _ ->
        source.url
    end
  end

  defp fetch_source(source, url) do
    Logger.info("Fetching RSS feed for source", source_url: url)

    case RSSClient.fetch_feed(url) do
      {:ok, news_items} ->
        NewsProcessor.process_and_save_news(news_items, source)

      {:error, reason} ->
        Logger.error("Failed to fetch RSS feed for #{url}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
