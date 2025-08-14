defmodule Bubble.Sources.TwitterClientTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.TwitterClient

  describe "fetch_tweets_since/2" do
    test "returns tweets since the specified time" do
      username = "testuser"
      start_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.to_iso8601()

      Req.Test.stub(TwitterClient, fn conn ->
        Req.Test.json(conn, mock_response_success())
      end)

      assert {:ok, %{"data" => _, "meta" => _}} =
               TwitterClient.fetch_tweets_since(username, start_time)
    end

    test "returns next valid time when rate limited" do
      username = "testuser"
      start_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.to_iso8601()

      Req.Test.stub(TwitterClient, fn conn ->
        conn = Plug.Conn.put_resp_header(conn, "x-rate-limit-reset", "1755204722")

        Plug.Conn.send_resp(
          conn,
          429,
          JSON.encode!(%{
            "detail" => "Too Many Requests",
            "status" => 429,
            "title" => "Too Many Requests",
            "type" => "about:blank"
          })
        )
      end)

      assert {:error, :rate_limited, ~U[2025-08-14 20:52:02Z]} =
               TwitterClient.fetch_tweets_since(username, start_time)
    end
  end

  defp mock_response_success do
    %{
      "data" => [
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-14T18:03:52.000Z",
          "edit_history_tweet_ids" => ["1956054178406473806"],
          "id" => "1956054178406473806",
          "text" => "@excid3 @inkyvoxel @andrewmcodes Lovely! DMed!"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-14T16:05:16.000Z",
          "edit_history_tweet_ids" => ["1956024332137721986"],
          "id" => "1956024332137721986",
          "text" =>
            "RT @thruflo: Awesome work by the @ElectricSQL engineering team. Fresh from the 120 day hardening sprint and handling 20k writes per second…"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-14T15:52:13.000Z",
          "edit_history_tweet_ids" => ["1956021048383566028"],
          "id" => "1956021048383566028",
          "text" =>
            "We are nearing the release of Tidewave Web for Rails and Phoenix and I would love to reach out to the Ruby/Rails communities. Therefore, what is your favorite Ruby/Rails podcast?"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-14T15:30:09.000Z",
          "edit_history_tweet_ids" => ["1956015496253321570"],
          "id" => "1956015496253321570",
          "text" =>
            "@derrickreimer @pascallaliberte Yup! That's exactly what we built for Phoenix and Rails: https://t.co/0YAqenFgRF :) We are also on beta for the next iteration of Tidewave, that goes beyond the MCP, and I'll be glad to send you an invite, just DM me!"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-14T07:11:32.000Z",
          "edit_history_tweet_ids" => ["1955890013817704476"],
          "id" => "1955890013817704476",
          "text" =>
            "@guillaumebriday @rails That's exactly what we built for Phoenix and Rails: https://t.co/0YAqenFgRF :) We are also on beta for the next iteration of Tidewave, that goes beyond the MCP, and I'll be glad to send you an invite, just DM me!"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-13T16:15:31.000Z",
          "edit_history_tweet_ids" => ["1955664522368475249"],
          "id" => "1955664522368475249",
          "text" => "@vendraminiravi Obrigado😂"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-13T01:45:49.000Z",
          "edit_history_tweet_ids" => ["1955445654475641212"],
          "id" => "1955445654475641212",
          "text" =>
            "RT @chgeuer: Wrote a small library to play with rendevouz hashing, similar to HCA Healthcare's Project Waterpark, and a visualization in @l…"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-12T18:56:38.000Z",
          "edit_history_tweet_ids" => ["1955342682089263309"],
          "id" => "1955342682089263309",
          "text" =>
            "RT @derrickreimer: To my Laravel &amp; Rails friends:\n\nICYMI, I'm hiring a full-stack developer to join SavvyCal. \n\nWe use Elixir/Phoenix, but…"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-11T15:20:39.000Z",
          "edit_history_tweet_ids" => ["1954925939915428202"],
          "id" => "1954925939915428202",
          "text" =>
            "RT @ElixirMembrane: Elixir devs, your global meetup network has just arrived 💎\n\nFind your nearest GEM or host your own (pizza is on us!): h…"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-10T05:55:46.000Z",
          "edit_history_tweet_ids" => ["1954421394579603673"],
          "id" => "1954421394579603673",
          "text" =>
            "RT @_csinclair_: This talk from @thruflo on Phoenix.Sync was sooo good at Elixirconf! Can't recommend strongly enough giving it a watch! 📽️…"
        },
        %{
          "author_id" => "10230812",
          "created_at" => "2025-08-08T18:36:18.000Z",
          "edit_history_tweet_ids" => ["1953888011676197030"],
          "id" => "1953888011676197030",
          "text" =>
            "RT @charliebholtz: here's an open question we're trying to figure out: which of these hypotheses is right? \n\n1) models matter, agents don’t…"
        }
      ],
      "meta" => %{
        "newest_id" => "1956054178406473806",
        "oldest_id" => "1953888011676197030",
        "result_count" => 11
      }
    }
  end
end
