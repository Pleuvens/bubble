defmodule Bubble.News.SourceOverride do
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

  defp custom(%UserNewsSource{} = user_source, field) do
    case Map.fetch!(user_source, field) do
      blank when blank in [nil, ""] -> nil
      value -> value
    end
  end

  defp custom(_no_subscription, _field), do: nil
end
