defmodule BubbleWeb.Components.SourceEditForm do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.CoreComponents
  import BubbleWeb.Components.FieldLabel

  attr :source_id, :any, required: true
  attr :edit_form, :map, required: true

  def source_edit_form(assigns) do
    ~H"""
    <form phx-submit="save_source" phx-value-id={@source_id} class="space-y-3">
      <div class="space-y-1.5">
        <.field_label for={"edit_name_#{@source_id}"}>Name</.field_label>
        <.text_input
          type="text"
          id={"edit_name_#{@source_id}"}
          name="name"
          value={@edit_form.name}
          required
          class="py-2 text-sm"
        />
      </div>
      <div class="space-y-1.5">
        <.field_label for={"edit_url_#{@source_id}"}>RSS URL</.field_label>
        <.text_input
          type="url"
          id={"edit_url_#{@source_id}"}
          name="url"
          value={@edit_form.url}
          required
          class="py-2 text-sm"
        />
      </div>
      <div class="space-y-1.5">
        <.field_label for={"edit_description_#{@source_id}"}>Description</.field_label>
        <.text_area
          id={"edit_description_#{@source_id}"}
          name="description"
          rows="2"
          value={@edit_form.description}
        />
      </div>
      <div class="flex gap-2">
        <button
          type="submit"
          class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-lg text-[13px] font-semibold uppercase tracking-wide transition-colors"
        >
          Save
        </button>
        <button
          type="button"
          phx-click="cancel_edit"
          class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2 rounded-lg text-[13px] font-semibold uppercase tracking-wide transition-colors"
        >
          Cancel
        </button>
      </div>
    </form>
    """
  end
end
