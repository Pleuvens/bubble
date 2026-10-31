defmodule Bubble.NewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bubble.News` and `Bubble.NewsSources` contexts.
  """

  alias Bubble.News.News
  alias Bubble.NewsSources
  alias Bubble.Repo

  @doc """
  Generate a news source.
  """
  def news_source_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Test Source #{System.unique_integer()}",
        url: "https://example#{System.unique_integer()}.com/rss",
        description: "Test source description"
      })

    {:ok, news_source} = NewsSources.create_source(attrs)
    news_source
  end

  @doc """
  Generate news.
  """
  def news_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "Test News Title",
        description: "Test description for the news article",
        content: "Test content for the news article",
        url: "https://example.com/test#{System.unique_integer()}",
        published_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    %News{}
    |> News.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Subscribe a user to a news source.
  """
  def subscribe_user_to_source(user_id, news_source_id) do
    {:ok, _} = NewsSources.subscribe_user_and_fetch(user_id, news_source_id)
  end

  def subscribed_news_source_fixture(user_id, attrs \\ %{}) do
    news_source = news_source_fixture(attrs)
    subscribe_user_to_source(user_id, news_source.id)
    news_source
  end

  def subscribed_news_fixture(user_id, attrs \\ []) do
    news_source = subscribed_news_source_fixture(user_id)
    news = news_fixture(Keyword.put(attrs, :news_source_id, news_source.id))
    {news_source, news}
  end

  def subscribed_news_list_fixture(user_id, count \\ 3) do
    news_source = subscribed_news_source_fixture(user_id)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    for position <- 1..count do
      news_fixture(
        title: "Test News Title #{position}",
        description: "Test description for the news article #{position}",
        content: "Test content for the news article #{position}",
        published_at: DateTime.add(now, -position, :minute),
        news_source_id: news_source.id
      )
    end
  end

  # Backward compatibility aliases
  def feed_source_fixture(attrs \\ %{}), do: news_source_fixture(attrs)
  def feed_fixture(attrs \\ %{}), do: news_fixture(attrs)
end
