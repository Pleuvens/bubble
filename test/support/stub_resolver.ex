defmodule Bubble.Support.StubResolver do
  @addresses_by_host %{
    ~c"loopback.test" => {127, 0, 0, 1},
    ~c"metadata.test" => {169, 254, 169, 254},
    ~c"private.test" => {10, 0, 0, 5}
  }

  @public_address {93, 184, 216, 34}

  def resolve(hostname, :inet, _timeout) do
    {:ok, [Map.get(@addresses_by_host, hostname, @public_address)]}
  end

  def resolve(_hostname, :inet6, _timeout) do
    {:error, :nxdomain}
  end
end
