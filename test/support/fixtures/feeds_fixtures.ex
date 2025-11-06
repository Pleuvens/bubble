defmodule Bubble.FeedsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bubble.Feeds` and `Bubble.Sources` contexts.
  """

  alias Bubble.Feeds.Feed
  alias Bubble.Sources
  alias Bubble.Repo

  @doc """
  Generate a feed source.
  """
  def feed_source_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Test Source #{System.unique_integer()}",
        url: "https://example#{System.unique_integer()}.com/rss",
        description: "Test source description",
        is_active: true
      })

    {:ok, feed_source} = Sources.create_source(attrs)
    feed_source
  end

  @doc """
  Generate a feed.
  """
  def feed_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "Test News Title",
        description: "Test description for the news article",
        content: "Test content for the news article",
        url: "https://example.com/test#{System.unique_integer()}",
        published_at: ~U[2024-01-01 00:00:00Z]
      })

    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Subscribe a user to a feed source.
  """
  def subscribe_user_to_source(user_id, feed_source_id) do
    {:ok, _} = Sources.add_user_source(user_id, feed_source_id)
  end
end
