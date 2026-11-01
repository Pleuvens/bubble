defmodule Utils.FetchGuard do
  @pool_max_idle_time 60_000
  @default_resolver &:inet.getaddrs/3
  @default_resolution_timeout 2_000

  def attach(%Req.Request{} = request) do
    request
    |> Req.Request.append_request_steps(pin_connection: &pin_connection/1)
    |> ReqSSRF.attach(check_options())
  end

  defp pin_connection(%Req.Request{} = request) do
    host = request.url.host

    cond do
      host in [nil, ""] -> request
      host == pinned_address(request) -> request
      ip_address?(host) -> drop_pin(request)
      true -> pin_to_resolved_address(request, host)
    end
  end

  defp pin_to_resolved_address(request, host) do
    case resolve_ipv4(host) do
      {:ok, address} -> pin(request, address, host)
      {:error, reason} -> block(request, reason)
    end
  end

  defp pin(%Req.Request{url: %URI{} = url} = request, address, host) do
    pinned = address |> :inet.ntoa() |> to_string()

    %{request | url: %URI{url | host: pinned}}
    |> Req.Request.put_private(:pinned_address, pinned)
    |> put_option(:connect_options, hostname: host)
    |> put_option(:pool_max_idle_time, @pool_max_idle_time)
  end

  defp drop_pin(request) do
    request
    |> Req.Request.put_private(:pinned_address, nil)
    |> Req.Request.delete_option(:connect_options)
  end

  defp block(request, reason) do
    Req.Request.halt(request, %ReqSSRF.BlockedError{url: request.url, reason: reason})
  end

  defp resolve_ipv4(host) do
    case resolver().(to_charlist(host), :inet, resolution_timeout()) do
      {:ok, [address | _rest]} -> {:ok, address}
      {:ok, []} -> {:error, :unresolvable_host}
      {:error, _reason} -> {:error, :unresolvable_host}
    end
  end

  defp pinned_address(request), do: Req.Request.get_private(request, :pinned_address)

  defp ip_address?(host) do
    match?({:ok, _address}, host |> to_charlist() |> :inet.parse_address())
  end

  defp put_option(request, key, value), do: put_in(request.options[key], value)

  defp resolver, do: Keyword.get(check_options(), :resolver, @default_resolver)

  defp resolution_timeout do
    Keyword.get(check_options(), :timeout, @default_resolution_timeout)
  end

  defp check_options do
    Application.get_env(:bubble, :ssrf_check_options, [])
  end
end
