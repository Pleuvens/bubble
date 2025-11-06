defmodule Bubble.Repo.Migrations.RenameFeedsToNews do
  use Ecto.Migration

  def change do
    # Rename tables in order to maintain referential integrity
    rename table(:feed_sources), to: table(:news_sources)
    rename table(:feeds), to: table(:news)
    rename table(:users_feed_sources), to: table(:users_news_sources)
  end
end
