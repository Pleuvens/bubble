defmodule Bubble.Repo.Migrations.AddDescriptionAndIsActiveToFeedSources do
  use Ecto.Migration

  def change do
    alter table(:feed_sources) do
      add :description, :text
      add :is_active, :boolean, default: true, null: false
    end
  end
end
