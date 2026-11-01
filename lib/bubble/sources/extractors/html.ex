defmodule Bubble.Sources.Extractors.Html do
  @behaviour Bubble.Sources.Extractors.Extractor

  alias Bubble.Sources.Extractors.Utils

  @impl true
  def extract_description(html) do
    Utils.fetch_content(html, {:meta_content, ~s(meta[name="description"])})
  end

  @impl true
  def extract_title(html) do
    Utils.fetch_content(html, {:element_text, "title"})
  end
end
