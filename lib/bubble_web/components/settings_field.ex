defmodule BubbleWeb.Components.SettingsField do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.Components.FieldLabel

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :type, :string, required: true
  attr :label, :string, required: true
  attr :value, :any, default: nil
  attr :required, :boolean, default: true
  attr :debounce, :boolean, default: false
  slot :error

  def settings_field(assigns) do
    ~H"""
    <div class="space-y-1.5">
      <.field_label for={@id}>{@label}</.field_label>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        required={@required}
        phx-debounce={@debounce && "blur"}
        class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white transition"
      />
      {render_slot(@error)}
    </div>
    """
  end

  slot :inner_block, required: true

  def settings_submit_button(assigns) do
    ~H"""
    <button
      type="submit"
      class="w-full py-3.5 rounded-lg bg-orange-400 hover:bg-orange-500 text-white uppercase text-[13px] font-bold tracking-wide transition-colors"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
