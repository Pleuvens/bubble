defmodule Bubble.Repo do
  use Ecto.Repo,
    otp_app: :bubble,
    adapter: Ecto.Adapters.Postgres
end
