defmodule Bubble.News.SourceOverrideTest do
  use ExUnit.Case, async: true

  alias Bubble.News.NewsSource
  alias Bubble.News.SourceOverride
  alias Bubble.News.UserNewsSource

  setup do
    %{
      source: %NewsSource{
        name: "Bluesky",
        url: "https://bsky.app/rss",
        description: "Shared description"
      }
    }
  end

  test "falls back to the shared source when there is no subscription", %{source: source} do
    assert SourceOverride.name(source, nil) == "Bluesky"
    assert SourceOverride.description(source, nil) == "Shared description"
    assert SourceOverride.url(source, nil) == "https://bsky.app/rss"
  end

  test "falls back to the shared source when the subscription sets nothing", %{source: source} do
    user_source = %UserNewsSource{}

    assert SourceOverride.name(source, user_source) == "Bluesky"
    assert SourceOverride.description(source, user_source) == "Shared description"
    assert SourceOverride.url(source, user_source) == "https://bsky.app/rss"
  end

  test "treats a blank override as unset", %{source: source} do
    user_source = %UserNewsSource{custom_name: "", custom_description: "", custom_url: ""}

    assert SourceOverride.name(source, user_source) == "Bluesky"
    assert SourceOverride.description(source, user_source) == "Shared description"
    assert SourceOverride.url(source, user_source) == "https://bsky.app/rss"
  end

  test "prefers the subscriber's own values", %{source: source} do
    user_source = %UserNewsSource{
      custom_name: "My Bluesky",
      custom_description: "My description",
      custom_url: "https://bsky.app/custom.xml"
    }

    assert SourceOverride.name(source, user_source) == "My Bluesky"
    assert SourceOverride.description(source, user_source) == "My description"
    assert SourceOverride.url(source, user_source) == "https://bsky.app/custom.xml"
  end
end
