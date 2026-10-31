defmodule Bubble.Sources.Extractors.Extractor do
  @moduledoc """
  Behaviour for extracting metadata from HTML content.

  Implementations say where their metadata lives, as a `Utils.locator/0`:
  a meta tag whose `content` attribute holds the value, or an element whose
  text holds it.

  ## Usage

      defmodule MyExtractor do
        use Bubble.Sources.Extractors.Extractor

        @impl true
        def description_locator, do: {:meta_content, ~s(meta[name="description"])}

        @impl true
        def title_locator, do: {:element_text, "title"}
      end

  The default implementations of `extract_description/1` and `extract_title/1`
  will use these locators automatically. You can override these functions
  if you need custom extraction logic.
  """

  alias Bubble.Sources.Extractors.Utils

  @doc """
  Returns the locator for the description.
  """
  @callback description_locator() :: Utils.locator()

  @doc """
  Returns the locator for the title.
  """
  @callback title_locator() :: Utils.locator()

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
      Extracts description from HTML using the module's locator.
      """
      def extract_description(html) do
        extract_with_locator(html, description_locator())
      end

      @doc """
      Extracts title from HTML using the module's locator.
      """
      def extract_title(html) do
        extract_with_locator(html, title_locator())
      end

      defp extract_with_locator(html, locator) do
        case Utils.extract_content(html, locator) do
          nil -> {:error, :not_found}
          content -> {:ok, content}
        end
      end

      defoverridable extract_description: 1, extract_title: 1
    end
  end
end
