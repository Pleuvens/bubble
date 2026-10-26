defmodule Utils.FeedUrl do
  import Ecto.Changeset

  @fetchable_schemes ["http", "https"]

  def fetchable?(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host}
      when scheme in @fetchable_schemes and is_binary(host) and host != "" ->
        true

      _ ->
        false
    end
  end

  def fetchable?(_url), do: false

  def validate_fetchable(changeset, field) do
    validate_change(changeset, field, fn ^field, url ->
      if fetchable?(url),
        do: [],
        else: [{field, "must start with http:// or https:// and include a domain"}]
    end)
  end
end
