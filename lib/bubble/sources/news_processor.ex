defmodule Bubble.Sources.NewsProcessor do
  @moduledoc """
  Processes and saves news items from RSS feeds.
  Handles content extraction, date parsing, and database insertion.
  """

  import Ecto.Query

  alias Bubble.News.News
  alias Bubble.News.NewsSource
  alias Bubble.Repo
  alias Bubble.Sources.MetaScraper

  require Logger

  @doc """
  Processes news items for a given source and saves them to the database.
  Updates the source's last_fetched_at timestamp.

  Returns :ok on success, {:error, reason} on failure.
  """
  def process_and_save_news(news_items, source) when is_list(news_items) do
    news_to_insert =
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
        |> Map.put(:news_source_id, source.id)
      end)

    Repo.insert_all(News, news_to_insert)

    source
    |> Ecto.Changeset.change(last_fetched_at: DateTime.utc_now())
    |> Repo.update()

    Logger.info("Successfully fetched #{length(news_items)} items from #{source.url}")
    :ok
  end

  @doc """
  Processes news items for multiple sources and saves them to the database.
  Updates all sources' last_fetched_at timestamps.

  Takes a list of sources and a map of fetched news keyed by URL.
  Returns :ok on success.
  """
  def process_and_save_news_batch(sources, fetched_news) when is_list(sources) do
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

    # Update last_fetched_at only for successfully fetched sources
    successfully_fetched_source_ids =
      fetched_news
      |> Enum.filter(fn {_url, result} -> match?({:ok, _}, result) end)
      |> Enum.map(fn {source_url, _result} -> Map.get(url_to_source_id, source_url) end)
      |> Enum.reject(&is_nil/1)

    if successfully_fetched_source_ids != [] do
      from(ns in NewsSource, where: ns.id in ^successfully_fetched_source_ids)
      |> Repo.update_all(set: [last_fetched_at: DateTime.utc_now()])
    end

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
