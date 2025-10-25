defmodule Bubble.Repo.Migrations.ChangeFeedsTitleAndUrlToText do
  use Ecto.Migration

  def up do
    alter table(:feeds) do
      modify :title, :text, null: false
      modify :url, :text, null: false
    end
  end

  def down do
    alter table(:feeds) do
      modify :title, :string, null: false
      modify :url, :string, null: false
    end
  end
end
