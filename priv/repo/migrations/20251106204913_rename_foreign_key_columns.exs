defmodule Bubble.Repo.Migrations.RenameForeignKeyColumns do
  use Ecto.Migration

  def change do
    # Rename foreign key columns to match new naming
    rename table(:news), :feed_source_id, to: :news_source_id
    rename table(:users_news_sources), :feed_source_id, to: :news_source_id
  end
end
