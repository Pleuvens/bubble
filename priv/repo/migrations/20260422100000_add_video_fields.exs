defmodule Bubble.Repo.Migrations.AddVideoFields do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :content_type, :text, null: false, default: "article"
    end

    create constraint(:news_sources, :content_type_must_be_valid,
             check: "content_type IN ('article', 'video')"
           )

    alter table(:news) do
      add :video_id, :text
      add :thumbnail_url, :text
    end
  end
end
