defmodule Bubble.Sources.TwitterClient do
  require Logger

  def fetch_tweets_since(username, start_time) do
    query = "from:#{username}"

    req_base()
    |> Req.get(
      url: "tweets/search/recent",
      params: %{
        "query" => query,
        "start_time" => start_time,
        "tweet.fields" => "created_at,text,attachments,author_id",
        "max_results" => "100"
      }
    )
    |> handle_response()
  end

  defp req_base do
    bearer = Application.get_env(:bubble, :twitter_bearer_token)

    [
      base_url: "https://api.twitter.com/2",
      auth: {:bearer, bearer}
    ]
    |> Keyword.merge(Application.get_env(:bubble, :twitter_client_req_options, []))
    |> Req.new()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:ok, %Req.Response{status: 429, headers: headers}}) do
    rate_limit_reset_date =
      headers["x-rate-limit-reset"]
      |> Enum.at(0)
      |> String.to_integer()
      |> DateTime.from_unix!()

    {:error, :rate_limited, rate_limit_reset_date}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    Logger.warning("Twitter API request failed with status #{status}: #{inspect(body)}")
    {:error, :invalid_request}
  end

  defp handle_response({:error, %Req.TransportError{reason: reason}}) do
    Logger.warning("Twitter API request failed: #{inspect(reason)}")
    {:error, :request_failed}
  end
end
