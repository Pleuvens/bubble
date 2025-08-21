defmodule Bubble.Sources.FirecrawlClient do
  require Logger

  def fetch_feed_content(url) do
    Req.post(
      url: "https://api.firecrawl.dev/v2/scrape",
      auth: {:bearer, Application.get_env(:bubble, :firecrawl_api_key)},
      headers: [
        {"Content-Type", "application/json"}
      ],
      json: %{url: url, formats: [%{type: "summary"}]}
    )
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}) do
    {:ok, get_in(body, ["data", "summary"])}
  end

  defp handle_response(response) do
    Logger.warning("Failed to fetch content from Firecrawl API", response: inspect(response))
    {:error, :unhandlered_response}
  end
end
