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
        description: "Test source description",
        is_active: true
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
        published_at: ~U[2024-01-01 00:00:00Z]
      })

    %News{}
    |> News.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Subscribe a user to a news source.
  """
  def subscribe_user_to_source(user_id, news_source_id) do
    {:ok, _} = NewsSources.add_user_source(user_id, news_source_id)
  end

  # Backward compatibility aliases
  def feed_source_fixture(attrs \\ %{}), do: news_source_fixture(attrs)
  def feed_fixture(attrs \\ %{}), do: news_fixture(attrs)
end
