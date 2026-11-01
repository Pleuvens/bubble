defmodule Bubble.Sources.Extractors.Extractor do
  @callback extract_description(html :: String.t()) :: {:ok, String.t()} | {:error, :not_found}
  @callback extract_title(html :: String.t()) :: {:ok, String.t()} | {:error, :not_found}
end
