defmodule Bubble.News.SourceOverride do
  import Ecto.Query

  alias Bubble.News.NewsSource
  alias Bubble.News.UserNewsSource

  def name(%NewsSource{} = source, user_source) do
    custom(user_source, :custom_name) || source.name
  end

  def description(%NewsSource{} = source, user_source) do
    custom(user_source, :custom_description) || source.description
  end

  def url(%NewsSource{} = source, user_source) do
    custom(user_source, :custom_url) || source.url
  end

  def custom_urls_by_source_id do
    from uns in UserNewsSource,
      where: not is_nil(uns.custom_url) and uns.custom_url != "",
      select: {uns.news_source_id, uns.custom_url},
      distinct: true
  end

  defp custom(%UserNewsSource{} = user_source, field) do
    case Map.fetch!(user_source, field) do
      blank when blank in [nil, ""] -> nil
      value -> value
    end
  end

  defp custom(_no_subscription, _field), do: nil
end
