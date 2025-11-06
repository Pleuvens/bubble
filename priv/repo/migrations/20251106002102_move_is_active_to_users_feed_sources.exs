defmodule Bubble.Repo.Migrations.MoveIsActiveToUsersFeedSources do
  use Ecto.Migration

  def up do
    # Add is_active to users_feed_sources
    alter table(:users_feed_sources) do
      add :is_active, :boolean, default: true, null: false
    end

    # Remove is_active from feed_sources
    alter table(:feed_sources) do
      remove :is_active
    end
  end

  def down do
    # Add is_active back to feed_sources
    alter table(:feed_sources) do
      add :is_active, :boolean, default: true, null: false
    end

    # Remove is_active from users_feed_sources
    alter table(:users_feed_sources) do
      remove :is_active
    end
  end
end
