defmodule Bubble.Feeds.FetchNewsCronJob do
  alias Bubble.Sources.FirecrawlClient
  alias Bubble.Sources.MetaScraper
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
            is_nil(fs.last_fetched_at) or fragment("now() - ? > '1 day'", fs.last_fetched_at),
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
        content = fetch_content_with_fallback(news)

        published_at =
          case DateTime.from_iso8601(news.published_at) |> elem(1) do
            :invalid_format -> DateTime.utc_now() |> DateTime.truncate(:second)
            dt -> dt
          end

        %{
          news
          | published_at: published_at,
            content: content
        }
      end)

    Repo.insert_all(Feed, news_to_insert)

    Repo.update_all(
      from(fs in FeedSource,
        where: is_nil(fs.last_fetched_at) or fragment("now() - ? < '1 day'", fs.last_fetched_at)
      ),
      set: [last_fetched_at: DateTime.utc_now()]
    )

    :ok
  end

  # Hybrid approach: Try RSS data first, then MetaScraper, then Firecrawl as last resort
  defp fetch_content_with_fallback(news) do
    cond do
      # First: Use RSS content if available and substantial
      has_substantial_content?(news.content) ->
        news.content

      # Second: Use RSS description if available and substantial
      has_substantial_content?(news.description) ->
        news.description

      # Third: Try free MetaScraper (OpenGraph/Twitter/HTML meta tags)
      true ->
        case MetaScraper.fetch_description(news.url) do
          {:ok, description} ->
            Logger.debug("Fetched description via MetaScraper for #{news.url}")
            description

          {:error, _reason} ->
            # Fourth: Fall back to Firecrawl as last resort (expensive!)
            case FirecrawlClient.fetch_feed_content(news.url) do
              {:ok, summary} ->
                Logger.info("Used Firecrawl API for #{news.url}")
                summary

              _ ->
                "No description available"
            end
        end
    end
  end

  # Check if content is substantial (not empty, not just whitespace, has meaningful length)
  defp has_substantial_content?(nil), do: false
  defp has_substantial_content?(""), do: false

  defp has_substantial_content?(content) when is_binary(content) do
    trimmed = String.trim(content)
    trimmed != "" and String.length(trimmed) > 20
  end

  defp has_substantial_content?(_), do: false
end
