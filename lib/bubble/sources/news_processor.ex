defmodule Bubble.Sources.NewsProcessor do
  alias Bubble.News.News
  alias Bubble.News.NewsSource
  alias Bubble.Repo
  alias Bubble.Sources.MetaScraper
  alias Bubble.Sources.RSSValidator

  require Logger

  @minimum_substantial_content_length 20

  @spec process_and_save_news([RSSValidator.feed_item()], NewsSource.t()) :: :ok
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
    |> log_failed_touch(source)
  end

  defp log_failed_touch({:ok, _updated}, _source), do: :ok

  defp log_failed_touch({:error, changeset}, source) do
    Logger.warning(
      "Failed to update last_fetched_at: #{inspect(changeset.errors)} for URL #{source.url}"
    )

    :ok
  end

  defp fetch_content_with_fallback(news) do
    if video?(news), do: video_content(news), else: article_content(news)
  end

  defp video?(%{video_id: video_id}), do: video_id != ""

  defp video_content(%{description: description}) do
    if has_substantial_content?(description), do: description, else: ""
  end

  defp article_content(news) do
    cond do
      has_substantial_content?(news.content) -> news.content
      has_substantial_content?(news.description) -> news.description
      true -> scraped_description(news.url)
    end
  end

  defp scraped_description(url) do
    case MetaScraper.fetch_description(url) do
      {:ok, description} ->
        Logger.debug("Fetched description via MetaScraper for #{url}")
        description

      {:error, _reason} ->
        "No description available"
    end
  end

  defp has_substantial_content?(content) when is_binary(content) do
    String.length(String.trim(content)) > @minimum_substantial_content_length
  end
end
