defmodule Bubble.News.DeleteOldNewsJob do
  use Oban.Worker

  import Ecto.Query
  alias Bubble.Repo
  alias Bubble.News.News

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)

    {deleted_count, _} =
      from(n in News,
        where: n.inserted_at < ^thirty_days_ago
      )
      |> Repo.delete_all()

    {:ok, %{deleted_count: deleted_count}}
  end
end
