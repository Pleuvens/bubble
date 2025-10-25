defmodule Bubble.Sources.Extractors.TwitterCard do
  @moduledoc """
  Extracts Twitter Card metadata from HTML content.

  Twitter Cards enable rich media attachments on tweets that link to content.
  Many websites include Twitter Card meta tags alongside or instead of OpenGraph tags.

  More info: https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/markup
  """

  alias Bubble.Sources.Extractors.Utils

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a new TwitterCard extractor.
  """
  def new, do: %__MODULE__{}

  defimpl Bubble.Sources.Extractors.Extractor do
    alias Bubble.Sources.Extractors.Utils

    def extract_description(_extractor, html) do
      patterns = [
        ~r/<meta\s+name=["']twitter:description["']\s+content=["']([^"']+)["']/i,
        ~r/<meta\s+content=["']([^"']+)["']\s+name=["']twitter:description["']/i
      ]

      case Utils.extract_meta_content(html, patterns) do
        nil -> {:error, :not_found}
        description -> {:ok, description}
      end
    end

    def extract_title(_extractor, html) do
      patterns = [
        ~r/<meta\s+name=["']twitter:title["']\s+content=["']([^"']+)["']/i,
        ~r/<meta\s+content=["']([^"']+)["']\s+name=["']twitter:title["']/i
      ]

      case Utils.extract_meta_content(html, patterns) do
        nil -> {:error, :not_found}
        title -> {:ok, title}
      end
    end
  end
end
