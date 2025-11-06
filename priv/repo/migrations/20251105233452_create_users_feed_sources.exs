defmodule Bubble.Repo.Migrations.CreateUsersFeedSources do
  use Ecto.Migration

  def change do
    create table(:users_feed_sources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :feed_source_id, references(:feed_sources, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec, inserted_at: :created_at)
    end

    create unique_index(:users_feed_sources, [:user_id, :feed_source_id])
    create index(:users_feed_sources, [:user_id])
    create index(:users_feed_sources, [:feed_source_id])
  end
end
