defmodule Utils.FetchGuardTest do
  use ExUnit.Case, async: false

  alias Utils.FetchGuard

  @public_address {93, 184, 216, 34}
  @loopback_address {127, 0, 0, 1}

  setup do
    original = Application.get_env(:bubble, :ssrf_check_options, [])
    on_exit(fn -> Application.put_env(:bubble, :ssrf_check_options, original) end)
    :ok
  end

  describe "attach/1" do
    test "sends the request to the address it checked" do
      {:ok, request} = capture_request("https://feeds.example.com/rss", [@public_address])

      assert request.url.host == "93.184.216.34"
      assert request.url.path == "/rss"
      assert request.options.connect_options[:hostname] == "feeds.example.com"
    end

    test "retires the pool it opens for the address" do
      {:ok, request} = capture_request("https://feeds.example.com/rss", [@public_address])

      assert request.options.pool_max_idle_time > 0
    end

    test "a second answer from the resolver cannot move the request" do
      {:ok, request} =
        capture_request("https://feeds.example.com/rss", [@public_address, @loopback_address])

      assert request.url.host == "93.184.216.34"
      assert_received {:resolved, "feeds.example.com", :inet}
      refute_received {:resolved, "feeds.example.com", _family}
    end

    test "refuses a name that does not resolve" do
      assert {:error, %ReqSSRF.BlockedError{reason: :unresolvable_host}} =
               capture_request("https://feeds.example.com/rss", [])
    end

    test "leaves a URL that already names an address alone" do
      {:ok, request} = capture_request("http://8.8.8.8/latest", [])

      assert request.url.host == "8.8.8.8"
      refute request.options[:connect_options]
      refute_received {:resolved, _host, _family}
    end

    test "pins every redirect hop to its own address" do
      put_resolver([@public_address])

      Req.Test.stub(__MODULE__, fn conn ->
        send(self(), {:asked, conn.host})

        case conn.request_path do
          "/rss" ->
            conn
            |> Plug.Conn.put_resp_header("location", "http://8.8.8.8/landing")
            |> Plug.Conn.send_resp(302, "")

          "/landing" ->
            Req.Test.text(conn, "ok")
        end
      end)

      assert {:ok, %{status: 200}} =
               [url: "https://feeds.example.com/rss", plug: {Req.Test, __MODULE__}, retry: false]
               |> Req.new()
               |> FetchGuard.attach()
               |> Req.request()

      assert_received {:asked, "93.184.216.34"}
      assert_received {:asked, "8.8.8.8"}
    end
  end

  defp capture_request(url, answers) do
    put_resolver(answers)
    test = self()

    [url: url, retry: false]
    |> Req.new()
    |> FetchGuard.attach()
    |> Req.Request.append_request_steps(
      capture: fn request ->
        send(test, {:request, request})
        Req.Request.halt(request, Req.Response.new(status: 200, body: "ok"))
      end
    )
    |> Req.request()
    |> unwrap_captured_request()
  end

  defp unwrap_captured_request({:ok, _response}) do
    receive do
      {:request, request} -> {:ok, request}
    after
      0 -> flunk("the request never reached the adapter")
    end
  end

  defp unwrap_captured_request({:error, error}), do: {:error, error}

  defp put_resolver(answers) do
    Application.put_env(:bubble, :ssrf_check_options, resolver: resolver_answering(answers))
  end

  defp resolver_answering(answers) do
    {:ok, remaining} = Agent.start_link(fn -> answers end)
    test = self()

    fn
      hostname, :inet, _timeout ->
        send(test, {:resolved, to_string(hostname), :inet})
        {:ok, next_answers(remaining)}

      hostname, :inet6, _timeout ->
        send(test, {:resolved, to_string(hostname), :inet6})
        {:error, :nxdomain}
    end
  end

  defp next_answers(remaining) do
    Agent.get_and_update(remaining, fn
      [] -> {[], []}
      [address | rest] -> {[address], rest}
    end)
  end
end
