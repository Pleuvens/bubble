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

  def get_source(id) do
    Repo.get(FeedSource, id)
  end

  def update_source(source, attrs) do
    source
    |> FeedSource.changeset(attrs)
    |> Repo.update()
  end
end
