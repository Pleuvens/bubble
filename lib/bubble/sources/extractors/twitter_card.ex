defmodule Bubble.Sources.Extractors.TwitterCard do
  @moduledoc """
  Extracts Twitter Card metadata from HTML content.

  Twitter Cards enable rich media attachments on tweets that link to content.
  Many websites include Twitter Card meta tags alongside or instead of OpenGraph tags.

  More info: https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/markup
  """

  use Bubble.Sources.Extractors.Extractor

  @impl true
  def description_patterns do
    [
      ~r/<meta\s+name=["']twitter:description["']\s+content=["']([^"']+)["']/i,
      ~r/<meta\s+content=["']([^"']+)["']\s+name=["']twitter:description["']/i
    ]
  end

  @impl true
  def title_patterns do
    [
      ~r/<meta\s+name=["']twitter:title["']\s+content=["']([^"']+)["']/i,
      ~r/<meta\s+content=["']([^"']+)["']\s+name=["']twitter:title["']/i
    ]
  end
end
