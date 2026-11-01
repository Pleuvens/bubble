defmodule Bubble.Sources.NewsProcessor do
  alias Bubble.News.News
  alias Bubble.Repo
  alias Bubble.Sources.MetaScraper

  require Logger

  @minimum_substantial_content_length 20

  def process_and_save_news(news_items, source) when is_list(news_items) do
    news_items
    |> build_news_rows(source)
    |> insert_skipping_duplicate_urls()

    touch_last_fetched_at(source)

    Logger.info("Successfully fetched #{length(news_items)} items from #{source.url}")
    :ok
  end

  defp build_news_rows(news_items, source) do
    Enum.map(news_items, &build_news_row(&1, source))
  end

  defp build_news_row(news, source) do
    news
    |> Map.put(:published_at, parse_published_at(news.published_at))
    |> Map.put(:content, fetch_content_with_fallback(news))
    |> Map.put(:news_source_id, source.id)
  end

  defp parse_published_at(published_at) do
    case DateTime.from_iso8601(published_at) do
      {:ok, datetime, _offset} -> datetime
      {:error, _reason} -> DateTime.utc_now() |> DateTime.truncate(:second)
    end
  end

  defp insert_skipping_duplicate_urls(news_rows) do
    Repo.insert_all(News, news_rows, on_conflict: :nothing)
  end

  defp touch_last_fetched_at(source) do
    source
    |> Ecto.Changeset.change(last_fetched_at: DateTime.utc_now())
    |> Repo.update()
  end

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

  defp has_substantial_content?(nil), do: false
  defp has_substantial_content?(""), do: false

  defp has_substantial_content?(content) when is_binary(content) do
    trimmed = String.trim(content)
    String.length(trimmed) > @minimum_substantial_content_length
  end

  defp has_substantial_content?(_), do: false
end
