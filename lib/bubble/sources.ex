defmodule Bubble.Sources do
  import Ecto.Query

  alias Bubble.Feeds.FeedSource
  alias Bubble.Repo

  def list_sources do
    Repo.all(FeedSource)
  end

  def delete_source(id) do
    Repo.delete_all(from s in FeedSource, where: s.id == ^id)
  end

  def add_source(attrs) do
    %FeedSource{}
    |> FeedSource.changeset(attrs)
    |> Repo.insert()
  end
end
