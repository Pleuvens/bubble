defmodule Bubble.Repo.Migrations.CreateFeedSources do
  use Ecto.Migration

  def up do
    create table(:feed_sources) do
      add :name, :string, null: false
      add :url, :string, null: false

      add :last_fetched_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:feed_sources, [:url])
    create index(:feed_sources, [:last_fetched_at])
    create index(:feed_sources, [:name])
  end

  def down do
    drop table(:feed_sources)
  end
end
