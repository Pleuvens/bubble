defmodule BubbleWeb.Components.SettingsField do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.CoreComponents
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
      <.text_input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        required={@required}
        phx-debounce={@debounce && "blur"}
      />
      {render_slot(@error)}
    </div>
    """
  end
end
