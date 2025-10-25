defmodule Bubble.Sources.Extractors.Html do
  @moduledoc """
  Extracts standard HTML meta tags and elements.

  This extractor handles basic HTML meta tags that don't follow
  OpenGraph or Twitter Card conventions:
  - Standard <meta name="description"> tags
  - <title> elements
  """

  use Bubble.Sources.Extractors.Extractor

  alias Bubble.Sources.Extractors.Utils

  @impl true
  def description_patterns do
    [
      ~r/<meta\s+name=["']description["']\s+content=["']([^"']+)["']/i,
      ~r/<meta\s+content=["']([^"']+)["']\s+name=["']description["']/i
    ]
  end

  @impl true
  def title_patterns do
    [~r/<title[^>]*>([^<]+)<\/title>/i]
  end

  # Override to use custom title extraction logic
  @impl true
  def extract_title(html) do
    pattern = ~r/<title[^>]*>([^<]+)<\/title>/i

    case Regex.run(pattern, html) do
      [_, title] ->
        case Utils.clean_text(title) do
          nil -> {:error, :not_found}
          cleaned_title -> {:ok, cleaned_title}
        end

      _ ->
        {:error, :not_found}
    end
  end
end
