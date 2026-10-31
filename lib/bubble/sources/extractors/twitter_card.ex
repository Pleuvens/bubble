defmodule Bubble.Sources.Extractors.TwitterCard do
  @moduledoc """
  Extracts Twitter Card metadata from HTML content.

  Twitter Cards enable rich media attachments on tweets that link to content.
  Many websites include Twitter Card meta tags alongside or instead of OpenGraph tags.

  More info: https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/markup
  """

  use Bubble.Sources.Extractors.Extractor

  @impl true
  def description_locator, do: {:meta_content, ~s(meta[name="twitter:description"])}

  @impl true
  def title_locator, do: {:meta_content, ~s(meta[name="twitter:title"])}
end
