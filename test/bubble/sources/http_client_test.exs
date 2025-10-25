defmodule Bubble.Sources.HttpClientTest do
  use ExUnit.Case, async: true

  alias Bubble.Sources.HttpClient

  setup do
    Req.Test.stub(HttpClient, fn conn ->
      Req.Test.json(conn, %{stubbed: true})
    end)

    :ok
  end

  describe "fetch_html/2" do
    test "returns HTML content for successful 200 response" do
      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.html(conn, "<html><body>Test Content</body></html>")
      end)

      assert {:ok, html} = HttpClient.fetch_html("https://example.com")
      assert html =~ "Test Content"
    end

    test "truncates large responses to max_size" do
      large_html = String.duplicate("a", 100_000)

      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.html(conn, large_html)
      end)

      assert {:ok, html} = HttpClient.fetch_html("https://example.com", max_size: 1000)
      assert byte_size(html) == 1000
    end

    test "returns error for 404 response" do
      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.json(conn, %{error: "Not Found"}, status: 404)
      end)

      assert {:error, :not_found} = HttpClient.fetch_html("https://example.com/missing")
    end

    test "returns error for 500 server error" do
      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.text(conn, "Internal Server Error", status: 500)
      end)

      assert {:error, :server_error} = HttpClient.fetch_html("https://example.com")
    end

    test "returns error for redirect responses" do
      Req.Test.expect(HttpClient, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("location", "https://example.com/new")
        |> Req.Test.text("Redirecting...", status: 302)
      end)

      assert {:error, :redirect} = HttpClient.fetch_html("https://example.com", max_redirects: 0)
    end

    test "returns error for timeout" do
      Req.Test.expect(HttpClient, fn _conn ->
        {:error, %{reason: :timeout}}
      end)

      assert {:error, :timeout} = HttpClient.fetch_html("https://example.com")
    end

    test "returns error for other request failures" do
      Req.Test.expect(HttpClient, fn _conn ->
        {:error, %{reason: :nxdomain}}
      end)

      assert {:error, :request_failed} = HttpClient.fetch_html("https://invalid.example")
    end

    test "respects custom timeout option" do
      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.html(conn, "<html>Success</html>")
      end)

      assert {:ok, _html} = HttpClient.fetch_html("https://example.com", timeout: 5000)
    end

    test "respects custom max_redirects option" do
      Req.Test.expect(HttpClient, fn conn ->
        Req.Test.html(conn, "<html>Success</html>")
      end)

      assert {:ok, _html} = HttpClient.fetch_html("https://example.com", max_redirects: 5)
    end
  end
end
