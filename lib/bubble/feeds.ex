defmodule Bubble.Feeds do
  import Ecto.Query

  alias Bubble.Feeds.Feed
  alias Bubble.Repo

  def list_news do
    Repo.all(
      from(f in Feed,
        order_by: [desc: f.published_at],
        limit: 10
      )
    )
  end
end
