defmodule BubbleWeb.Components.IconButton do
  @moduledoc false
  use Phoenix.Component

  attr :click, :string, required: true
  attr :source_id, :any, required: true
  attr :title, :string, required: true
  attr :icon, :atom, required: true, values: [:pencil, :refresh, :trash]
  attr :confirm, :string, default: nil
  attr :hover_tone, :atom, default: :orange, values: [:orange, :red]

  def icon_button(assigns) do
    ~H"""
    <button
      phx-click={@click}
      phx-value-id={@source_id}
      data-confirm={@confirm}
      title={@title}
      class={[
        "w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]",
        hover_text_class(@hover_tone)
      ]}
    >
      <.icon_glyph name={@icon} />
    </button>
    """
  end

  defp hover_text_class(:orange), do: "hover:text-orange-400"
  defp hover_text_class(:red), do: "hover:text-red-500"

  attr :name, :atom, required: true

  defp icon_glyph(%{name: :pencil} = assigns) do
    ~H"""
    <.glyph_svg>
      <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
    </.glyph_svg>
    """
  end

  defp icon_glyph(%{name: :refresh} = assigns) do
    ~H"""
    <.glyph_svg>
      <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" />
    </.glyph_svg>
    """
  end

  defp icon_glyph(%{name: :trash} = assigns) do
    ~H"""
    <.glyph_svg>
      <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
    </.glyph_svg>
    """
  end

  slot :inner_block, required: true

  defp glyph_svg(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="w-4 h-4"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      {render_slot(@inner_block)}
    </svg>
    """
  end
end
