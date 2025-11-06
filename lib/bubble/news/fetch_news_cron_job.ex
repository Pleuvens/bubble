defmodule Bubble.News.FetchNewsCronJob do
  alias Bubble.Sources.MetaScraper
  use Oban.Worker

  import Ecto.Query

  alias Bubble.News.News
  alias Bubble.News.NewsSource
  alias Bubble.Repo
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

    # Create a map of url -> news_source_id for quick lookup
    url_to_source_id =
      sources
      |> Enum.map(fn source -> {source.url, source.id} end)
      |> Map.new()

    news_to_insert =
      Enum.flat_map(fetched_news, fn {source_url, {:ok, news_items}} ->
        news_source_id = Map.get(url_to_source_id, source_url)

        Enum.map(news_items, fn news ->
          content = fetch_content_with_fallback(news)

          published_at =
            case DateTime.from_iso8601(news.published_at) |> elem(1) do
              :invalid_format -> DateTime.utc_now() |> DateTime.truncate(:second)
              dt -> dt
            end

          news
          |> Map.put(:published_at, published_at)
          |> Map.put(:content, content)
          |> Map.put(:news_source_id, news_source_id)
        end)
      end)

    Repo.insert_all(News, news_to_insert)

    Repo.update_all(
      from(ns in NewsSource,
        where: is_nil(ns.last_fetched_at) or fragment("now() - ? < '1 day'", ns.last_fetched_at)
      ),
      set: [last_fetched_at: DateTime.utc_now()]
    )

    :ok
  end

  # Hybrid approach: Try RSS data first, then MetaScraper
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
            "No description available"
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
