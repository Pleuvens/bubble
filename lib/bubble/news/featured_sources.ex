defmodule Bubble.News.FeaturedSources do
  @sources [
    %{
      name: "NBA Game Recaps",
      url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCWJ2lWNubArHWmf3FIHbfcQ",
      description: "Official NBA YouTube channel — game recaps and last night's summaries.",
      content_type: :video
    }
  ]

  def all, do: @sources

  def names, do: MapSet.new(@sources, & &1.name)

  def find_by_url(url), do: Enum.find(@sources, &(&1.url == url))
end
