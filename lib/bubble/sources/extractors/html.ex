defmodule Bubble.Sources.Extractors.Html do
  @moduledoc """
  Extracts standard HTML meta tags and elements.

  This extractor handles basic HTML meta tags that don't follow
  OpenGraph or Twitter Card conventions:
  - Standard <meta name="description"> tags
  - <title> elements
  """

  alias Bubble.Sources.Extractors.Utils

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a new HTML extractor.
  """
  def new, do: %__MODULE__{}

  defimpl Bubble.Sources.Extractors.Extractor do
    alias Bubble.Sources.Extractors.Utils

    def extract_description(_extractor, html) do
      patterns = [
        ~r/<meta\s+name=["']description["']\s+content=["']([^"']+)["']/i,
        ~r/<meta\s+content=["']([^"']+)["']\s+name=["']description["']/i
      ]

      case Utils.extract_meta_content(html, patterns) do
        nil -> {:error, :not_found}
        description -> {:ok, description}
      end
    end

    def extract_title(_extractor, html) do
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
end
