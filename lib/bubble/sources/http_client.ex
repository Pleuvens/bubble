defmodule Bubble.Sources.HttpClient do
  alias Utils.FetchGuard

  require Logger

  def fetch_html(url, opts \\ []) do
    max_size = Keyword.get(opts, :max_size, 51_200)

    url
    |> build_request(opts)
    |> Req.request()
    |> handle_response(url, max_size)
  end

  defp build_request(url, opts) do
    [
      url: url,
      max_redirects: Keyword.get(opts, :max_redirects, 3),
      receive_timeout: Keyword.get(opts, :timeout, 10_000)
    ]
    |> Keyword.merge(Application.get_env(:bubble, :http_client_req_options, []))
    |> Req.new()
    |> FetchGuard.attach()
  end

  defp handle_response({:error, %ReqSSRF.BlockedError{} = error}, _url, _max_size) do
    Logger.warning("Blocked fetch to an internal address: #{URI.to_string(error.url)}")
    {:error, :blocked_url}
  end

  defp handle_response({:ok, %{status: 200, body: body}}, _url, max_size)
       when is_binary(body) do
    {:ok, truncate_to(body, max_size)}
  end

  defp handle_response({:ok, %{status: 404}}, url, _max_size) do
    Logger.debug("Not found: #{url}")
    {:error, :not_found}
  end

  defp handle_response({:ok, %{status: status}}, url, _max_size)
       when status >= 500 do
    Logger.debug("Server error #{status} for #{url}")
    {:error, :server_error}
  end

  defp handle_response({:ok, %{status: status}}, url, _max_size) do
    Logger.debug("HTTP error #{status} for #{url}")
    {:error, :http_error}
  end

  defp handle_response({:error, %{reason: :timeout}}, url, _max_size) do
    Logger.debug("Timeout fetching #{url}")
    {:error, :timeout}
  end

  defp handle_response({:error, reason}, url, _max_size) do
    Logger.debug("Failed to fetch #{url}: #{inspect(reason)}")
    {:error, :request_failed}
  end

  defp truncate_to(body, max_size) do
    binary_part(body, 0, min(byte_size(body), max_size))
  end
end
