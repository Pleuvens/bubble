defmodule Bubble.Sources.Extractors.Html do
  @moduledoc """
  Extracts standard HTML meta tags and elements.

  This extractor handles basic HTML meta tags that don't follow
  OpenGraph or Twitter Card conventions:
  - Standard <meta name="description"> tags
  - <title> elements
  """

  use Bubble.Sources.Extractors.Extractor

  @impl true
  def description_locator, do: {:meta_content, ~s(meta[name="description"])}

  @impl true
  def title_locator, do: {:element_text, "title"}
end
