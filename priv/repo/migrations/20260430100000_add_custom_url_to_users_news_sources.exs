defmodule Bubble.Repo.Migrations.AddCustomUrlToUsersNewsSources do
  use Ecto.Migration

  def change do
    alter table(:users_news_sources) do
      add :custom_url, :text, null: true
    end
  end
end
