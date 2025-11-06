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
  """
  def list_user_news(user_id) do
    Repo.all(
      from(n in News,
        join: uns in UserNewsSource,
        on: uns.news_source_id == n.news_source_id,
        where: uns.user_id == ^user_id and uns.is_active == true,
        order_by: [desc: n.published_at],
        limit: 10
      )
    )
  end
end
