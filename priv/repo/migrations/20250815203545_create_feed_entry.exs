defmodule Bubble.Repo.Migrations.CreateFeedEntry do
  use Ecto.Migration

  def up do
    create table(:feeds) do
      add :title, :string, null: false
      add :url, :string, null: false
      add :published_at, :utc_datetime_usec, null: false
      add :description, :text, null: false
      add :content, :text, null: true

      timestamps()
    end

    create unique_index(:feeds, [:url])
    create index(:feeds, [:published_at])
  end

  def down do
    drop table(:feeds)
  end
end
