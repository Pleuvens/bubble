defmodule Bubble.Repo.Migrations.SetPublishedAtToTimestamptz do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      modify :published_at, :utc_datetime
    end
  end
end
