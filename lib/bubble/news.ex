defmodule Bubble.News do
  import Ecto.Query

  alias Bubble.News.News
  alias Bubble.News.SourceOverride
  alias Bubble.News.UserNewsSource
  alias Bubble.Repo

  @max_news_shown 50

  def list_user_news(user_id) do
    published_since = start_of_yesterday()

    Repo.all(
      from(n in News,
        join: uns in UserNewsSource,
        on: uns.news_source_id == n.news_source_id,
        where: uns.user_id == ^user_id and uns.is_active == true,
        where: n.published_at >= ^published_since,
        order_by: [desc: n.published_at],
        limit: @max_news_shown,
        preload: [:news_source],
        select: {n, uns}
      )
    )
    |> Enum.map(&apply_source_override/1)
  end

  defp start_of_yesterday do
    DateTime.utc_now()
    |> DateTime.shift(day: -1)
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp apply_source_override({news, user_source}) do
    source = news.news_source

    overridden = %{
      source
      | name: SourceOverride.name(source, user_source),
        description: SourceOverride.description(source, user_source)
    }

    %{news | news_source: overridden}
  end
end
