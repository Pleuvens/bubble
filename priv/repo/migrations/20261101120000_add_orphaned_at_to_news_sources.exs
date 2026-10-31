defmodule Bubble.Repo.Migrations.AddOrphanedAtToNewsSources do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :orphaned_at, :utc_datetime_usec
    end

    create index(:news_sources, [:orphaned_at])
  end
end
