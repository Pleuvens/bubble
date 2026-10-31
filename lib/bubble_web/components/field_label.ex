defmodule BubbleWeb.Components.FieldLabel do
  @moduledoc false
  use Phoenix.Component

  attr :for, :string, default: nil
  slot :inner_block, required: true

  def field_label(assigns) do
    ~H"""
    <label
      for={@for}
      class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
    >
      {render_slot(@inner_block)}
    </label>
    """
  end
end
