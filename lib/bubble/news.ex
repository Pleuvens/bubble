defmodule Bubble.News do
  import Ecto.Query

  alias Bubble.News.News
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo

  @doc """
  Lists all news (for backward compatibility or admin views).
  """
  def list_news do
    Repo.all(
      from(n in News,
        order_by: [desc: n.published_at],
        limit: 10
      )
    )
  end

  @doc """
  Lists news from sources the user is subscribed to and has active.
  Shows news from today and yesterday only.
  """
  def list_user_news(user_id) do
    # Get the start of yesterday (beginning of day, 1 day ago)
    yesterday_start =
      DateTime.utc_now()
      |> DateTime.shift(day: -1)
      |> DateTime.to_date()
      |> DateTime.new!(~T[00:00:00], "Etc/UTC")

    Repo.all(
      from(n in News,
        join: uns in UserNewsSource,
        on: uns.news_source_id == n.news_source_id,
        where: uns.user_id == ^user_id and uns.is_active == true,
        where: n.published_at >= ^yesterday_start,
        order_by: [desc: n.published_at]
      )
    )
  end
end
