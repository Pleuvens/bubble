defmodule BubbleWeb.Components.ActiveToggle do
  @moduledoc false
  use Phoenix.Component

  attr :source_id, :any, required: true
  attr :active, :boolean, required: true

  def active_toggle(assigns) do
    ~H"""
    <button
      phx-click="toggle_active"
      phx-value-id={@source_id}
      class={[
        "shrink-0 relative inline-flex items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2",
        "w-[46px] h-[27px]",
        if(@active, do: "bg-orange-400", else: "bg-gray-200 dark:bg-[#3f3f46]")
      ]}
    >
      <span class={[
        "inline-block w-[21px] h-[21px] transform rounded-full bg-white transition-transform",
        if(@active, do: "translate-x-[22px]", else: "translate-x-[3px]")
      ]}></span>
    </button>
    """
  end
end
