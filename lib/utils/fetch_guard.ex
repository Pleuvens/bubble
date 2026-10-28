defmodule Utils.FetchGuard do
  def attach(%Req.Request{} = request) do
    ReqSSRF.attach(request, check_options())
  end

  defp check_options do
    Application.get_env(:bubble, :ssrf_check_options, [])
  end
end
