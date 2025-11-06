defmodule Bubble.Repo.Migrations.AddFeedSourceIdToFeeds do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add :feed_source_id, references(:feed_sources, on_delete: :delete_all)
    end

    create index(:feeds, [:feed_source_id])
  end
end
