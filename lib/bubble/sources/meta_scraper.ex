defmodule Bubble.Sources.MetaScraper do
  @moduledoc """
  Orchestrates metadata extraction from URLs using multiple extraction strategies.

  This module:
  1. Fetches HTML content using HttpClient
  2. Tries extractors in priority order (OpenGraph → Twitter Card → HTML)
  3. Returns the first successful extraction
  """

  alias Bubble.Sources.HttpClient
  alias Bubble.Sources.Extractors.{OpenGraph, TwitterCard, Html}

  require Logger

  @default_extractors [
    OpenGraph,
    TwitterCard,
    Html
  ]

  @doc """
  Fetches a URL and extracts its description using multiple extraction strategies.

  Tries extractors in order:
  1. OpenGraph (og:description)
  2. Twitter Card (twitter:description)
  3. Standard HTML meta description

  Returns `{:ok, description}` if found, `{:error, reason}` otherwise.

  ## Options

    * `:extractors` - List of extractor modules to use (default: [OpenGraph, TwitterCard, Html])
    * `:http_opts` - Options to pass to HttpClient.fetch_html/2

  ## Examples

      iex> MetaScraper.fetch_description("https://example.com")
      {:ok, "Example Domain. This domain is for use in illustrative examples..."}

      iex> MetaScraper.fetch_description("https://invalid-url")
      {:error, :request_failed}
  """
  def fetch_description(url, opts \\ []) do
    extractors = Keyword.get(opts, :extractors, @default_extractors)
    http_opts = Keyword.get(opts, :http_opts, [])

    with {:ok, html} <- HttpClient.fetch_html(url, http_opts),
         {:ok, description} <- try_extractors(html, extractors, :description) do
      {:ok, description}
    else
      {:error, reason} ->
        Logger.debug("Failed to fetch description for #{url}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetches a URL and extracts its title using multiple extraction strategies.

  Tries extractors in order:
  1. OpenGraph (og:title)
  2. Twitter Card (twitter:title)
  3. Standard HTML <title> tag

  Returns `{:ok, title}` if found, `{:error, reason}` otherwise.

  ## Options

    * `:extractors` - List of extractor modules to use (default: [OpenGraph, TwitterCard, Html])
    * `:http_opts` - Options to pass to HttpClient.fetch_html/2

  ## Examples

      iex> MetaScraper.fetch_title("https://example.com")
      {:ok, "Example Domain"}
  """
  def fetch_title(url, opts \\ []) do
    extractors = Keyword.get(opts, :extractors, @default_extractors)
    http_opts = Keyword.get(opts, :http_opts, [])

    with {:ok, html} <- HttpClient.fetch_html(url, http_opts),
         {:ok, title} <- try_extractors(html, extractors, :title) do
      {:ok, title}
    else
      {:error, reason} ->
        Logger.debug("Failed to fetch title for #{url}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Try each extractor until one succeeds
  defp try_extractors(html, extractors, type) do
    result =
      Enum.find_value(extractors, fn extractor_module ->
        case extract(extractor_module, html, type) do
          {:ok, value} -> value
          {:error, :not_found} -> nil
        end
      end)

    case result do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  # Extract using the behavior module
  defp extract(extractor_module, html, :description) do
    extractor_module.extract_description(html)
  end

  defp extract(extractor_module, html, :title) do
    extractor_module.extract_title(html)
  end
end
