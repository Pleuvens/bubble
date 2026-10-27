defmodule Bubble.Repo.Migrations.AddCustomNameAndDescriptionToUsersNewsSources do
  use Ecto.Migration

  def change do
    alter table(:users_news_sources) do
      add :custom_name, :text, null: true
      add :custom_description, :text, null: true
    end
  end
end
