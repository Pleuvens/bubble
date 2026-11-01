defmodule Bubble.Sources.Extractors.OpenGraph do
  @behaviour Bubble.Sources.Extractors.Extractor

  alias Bubble.Sources.Extractors.Utils

  @impl true
  def extract_description(html) do
    Utils.fetch_content(html, {:meta_content, ~s(meta[property="og:description"])})
  end

  @impl true
  def extract_title(html) do
    Utils.fetch_content(html, {:meta_content, ~s(meta[property="og:title"])})
  end
end
