defmodule Utils.HtmlEntities do
  @entities [
    {"&amp;", "&"},
    {"&lt;", "<"},
    {"&gt;", ">"},
    {"&quot;", "\""},
    {"&apos;", "'"},
    {"&nbsp;", " "},
    {"&#32;", " "},
    {"&#39;", "'"},
    {"&#8216;", "'"},
    {"&#8217;", "'"},
    {"&#8220;", "\""},
    {"&#8221;", "\""}
  ]

  @spec decode(String.t()) :: String.t()
  def decode(text) when is_binary(text) do
    Enum.reduce(@entities, text, fn {entity, character}, decoded ->
      String.replace(decoded, entity, character)
    end)
  end
end
