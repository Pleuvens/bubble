defmodule Bubble.Sources.Extractors.Extractor do
  @moduledoc """
  Behaviour for extracting metadata from HTML content.

  Implementations should define patterns for extracting specific metadata
  (like titles, descriptions) from HTML using their specific patterns
  (OpenGraph, Twitter Card, standard HTML meta tags, etc.).

  ## Usage

  To implement an extractor, use this module and define the pattern callbacks:

      defmodule MyExtractor do
        use Bubble.Sources.Extractors.Extractor

        @impl true
        def description_patterns do
          [
            ~r/<meta\\s+name="description"\\s+content="([^"]+)"/i
          ]
        end

        @impl true
        def title_patterns do
          [
            ~r/<title>([^<]+)<\\/title>/i
          ]
        end
      end

  The default implementations of `extract_description/1` and `extract_title/1`
  will use these patterns automatically. You can override these functions
  if you need custom extraction logic.
  """

  alias Bubble.Sources.Extractors.Utils

  @doc """
  Returns regex patterns for extracting description from HTML.
  """
  @callback description_patterns() :: [Regex.t()]

  @doc """
  Returns regex patterns for extracting title from HTML.
  """
  @callback title_patterns() :: [Regex.t()]

  @doc """
  Extracts a description from the HTML content.

  Returns `{:ok, description}` if found, `{:error, :not_found}` otherwise.
  """
  @callback extract_description(html :: String.t()) :: {:ok, String.t()} | {:error, :not_found}

  @doc """
  Extracts a title from the HTML content.

  Returns `{:ok, title}` if found, `{:error, :not_found}` otherwise.
  """
  @callback extract_title(html :: String.t()) :: {:ok, String.t()} | {:error, :not_found}

  defmacro __using__(_opts) do
    quote do
      @behaviour Bubble.Sources.Extractors.Extractor

      @doc """
      Extracts description from HTML using the module's patterns.
      """
      def extract_description(html) do
        patterns = description_patterns()
        extract_with_patterns(html, patterns)
      end

      @doc """
      Extracts title from HTML using the module's patterns.
      """
      def extract_title(html) do
        patterns = title_patterns()
        extract_with_patterns(html, patterns)
      end

      # Helper to extract content using a list of patterns
      defp extract_with_patterns(html, patterns) do
        case Utils.extract_meta_content(html, patterns) do
          nil -> {:error, :not_found}
          content -> {:ok, content}
        end
      end

      # Allow overriding the default implementations
      defoverridable extract_description: 1, extract_title: 1
    end
  end
end
