defmodule Bubble.Sources.NewsProcessor do
  @moduledoc """
  Processes and saves news items from RSS feeds.
  Handles content extraction, date parsing, and database insertion.
  """

  alias Bubble.News.News
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
          case DateTime.from_iso8601(news.published_at) do
            {:ok, dt, _offset} -> dt
            {:error, _} -> DateTime.utc_now() |> DateTime.truncate(:second)
          end

        news
        |> Map.put(:published_at, published_at)
        |> Map.put(:content, content)
        |> Map.put(:news_source_id, source.id)
      end)

    # Insert news items, skipping any that violate the unique URL constraint
    Repo.insert_all(News, news_to_insert, on_conflict: :nothing)

    source
    |> Ecto.Changeset.change(last_fetched_at: DateTime.utc_now())
    |> Repo.update()

    Logger.info("Successfully fetched #{length(news_items)} items from #{source.url}")
    :ok
  end

  # For video items (YouTube etc.), use the RSS description directly — no scraping needed.
  # For articles, try RSS content/description first, then fall back to MetaScraper.
  defp fetch_content_with_fallback(news) do
    cond do
      news[:video_id] not in [nil, ""] ->
        if has_substantial_content?(news[:description]), do: news[:description], else: ""

      has_substantial_content?(news.content) ->
        news.content

      has_substantial_content?(news.description) ->
        news.description

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
