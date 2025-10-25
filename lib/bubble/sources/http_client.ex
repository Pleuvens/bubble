defmodule Bubble.Sources.HttpClient do
  @moduledoc """
  HTTP client for fetching web content with proper error handling.

  This module handles:
  - Fetching HTML content from URLs
  - Following redirects
  - Timeout management
  - Response size limiting to avoid downloading large files
  """

  require Logger

  @doc """
  Fetches HTML content from a URL.

  Returns `{:ok, html_string}` on success, `{:error, reason}` on failure.

  ## Options

    * `:max_redirects` - Maximum number of redirects to follow (default: 3)
    * `:timeout` - Request timeout in milliseconds (default: 10_000)
    * `:max_size` - Maximum response size in bytes (default: 51_200 / 50KB)

  ## Examples

      iex> HttpClient.fetch_html("https://example.com")
      {:ok, "<html>...</html>"}

      iex> HttpClient.fetch_html("https://invalid-url")
      {:error, :request_failed}
  """
  def fetch_html(url, opts \\ []) do
    max_redirects = Keyword.get(opts, :max_redirects, 3)
    timeout = Keyword.get(opts, :timeout, 10_000)
    max_size = Keyword.get(opts, :max_size, 51_200)

    request_opts =
      Keyword.merge(
        [
          url: url,
          max_redirects: max_redirects,
          receive_timeout: timeout
        ],
        Application.get_env(:bubble, :http_client_req_options, [])
      )

    url
    |> Req.get(request_opts)
    |> handle_response(url, max_size)
  end

  # Success: 200 OK with binary body
  defp handle_response({:ok, %{status: 200, body: body}}, _url, max_size)
       when is_binary(body) do
    # Truncate to max_size to avoid processing huge documents
    # Meta tags are typically in the <head> which is at the start
    truncated = binary_part(body, 0, min(byte_size(body), max_size))
    {:ok, truncated}
  end

  # Not found
  defp handle_response({:ok, %{status: 404}}, url, _max_size) do
    Logger.debug("Not found: #{url}")
    {:error, :not_found}
  end

  # Server errors
  defp handle_response({:ok, %{status: status}}, url, _max_size)
       when status >= 500 do
    Logger.debug("Server error #{status} for #{url}")
    {:error, :server_error}
  end

  # Other HTTP errors
  defp handle_response({:ok, %{status: status}}, url, _max_size) do
    Logger.debug("HTTP error #{status} for #{url}")
    {:error, :http_error}
  end

  # Timeout
  defp handle_response({:error, %{reason: :timeout}}, url, _max_size) do
    Logger.debug("Timeout fetching #{url}")
    {:error, :timeout}
  end

  # Other errors
  defp handle_response({:error, reason}, url, _max_size) do
    Logger.debug("Failed to fetch #{url}: #{inspect(reason)}")
    {:error, :request_failed}
  end
end
