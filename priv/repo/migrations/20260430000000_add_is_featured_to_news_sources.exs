defmodule Bubble.Repo.Migrations.AddIsFeaturedToNewsSources do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :is_featured, :boolean, null: false, default: false
    end

    # Mark existing video sources as featured (they came from the Discover catalog)
    execute(
      "UPDATE news_sources SET is_featured = true WHERE content_type = 'video'",
      "UPDATE news_sources SET is_featured = false WHERE content_type = 'video'"
    )
  end
end
