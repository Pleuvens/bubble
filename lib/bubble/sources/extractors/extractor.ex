defprotocol Bubble.Sources.Extractors.Extractor do
  @moduledoc """
  Protocol for extracting metadata from HTML content.

  Implementations should define how to extract specific metadata
  (like titles, descriptions) from HTML using their specific patterns
  (OpenGraph, Twitter Card, standard HTML meta tags, etc.).
  """

  @doc """
  Extracts a description from the HTML content.

  Returns `{:ok, description}` if found, `{:error, :not_found}` otherwise.
  """
  @spec extract_description(t(), String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def extract_description(extractor, html)

  @doc """
  Extracts a title from the HTML content.

  Returns `{:ok, title}` if found, `{:error, :not_found}` otherwise.
  """
  @spec extract_title(t(), String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def extract_title(extractor, html)
end
