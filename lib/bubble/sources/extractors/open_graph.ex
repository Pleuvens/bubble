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
  def description_patterns do
    [
      ~r/<meta\s+property=["']og:description["']\s+content=["']([^"']+)["']/i,
      ~r/<meta\s+content=["']([^"']+)["']\s+property=["']og:description["']/i
    ]
  end

  @impl true
  def title_patterns do
    [
      ~r/<meta\s+property=["']og:title["']\s+content=["']([^"']+)["']/i,
      ~r/<meta\s+content=["']([^"']+)["']\s+property=["']og:title["']/i
    ]
  end
end
