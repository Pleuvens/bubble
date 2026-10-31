defmodule Bubble.Sources.Extractors.OpenGraph do
  @moduledoc """
  Extracts OpenGraph metadata from HTML content.

  OpenGraph is a protocol developed by Facebook that enables web pages
  to become rich objects in a social graph. Most modern websites include
  OpenGraph tags for better social media sharing.

  More info: https://ogp.me/
  """

  use Bubble.Sources.Extractors.Extractor

  @impl true
  def description_locator, do: {:meta_content, ~s(meta[property="og:description"])}

  @impl true
  def title_locator, do: {:meta_content, ~s(meta[property="og:title"])}
end
