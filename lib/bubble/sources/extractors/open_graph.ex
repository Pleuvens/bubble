defmodule Bubble.Sources.Extractors.OpenGraph do
  @moduledoc """
  Extracts OpenGraph metadata from HTML content.

  OpenGraph is a protocol developed by Facebook that enables web pages
  to become rich objects in a social graph. Most modern websites include
  OpenGraph tags for better social media sharing.

  More info: https://ogp.me/
  """

  alias Bubble.Sources.Extractors.Utils

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a new OpenGraph extractor.
  """
  def new, do: %__MODULE__{}

  defimpl Bubble.Sources.Extractors.Extractor do
    alias Bubble.Sources.Extractors.Utils

    def extract_description(_extractor, html) do
      patterns = [
        ~r/<meta\s+property=["']og:description["']\s+content=["']([^"']+)["']/i,
        ~r/<meta\s+content=["']([^"']+)["']\s+property=["']og:description["']/i
      ]

      case Utils.extract_meta_content(html, patterns) do
        nil -> {:error, :not_found}
        description -> {:ok, description}
      end
    end

    def extract_title(_extractor, html) do
      patterns = [
        ~r/<meta\s+property=["']og:title["']\s+content=["']([^"']+)["']/i,
        ~r/<meta\s+content=["']([^"']+)["']\s+property=["']og:title["']/i
      ]

      case Utils.extract_meta_content(html, patterns) do
        nil -> {:error, :not_found}
        title -> {:ok, title}
      end
    end
  end
end
