defmodule BubbleWeb.Components.SourceEditForm do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.Components.FieldLabel

  attr :source_id, :any, required: true
  attr :edit_form, :map, required: true

  def source_edit_form(assigns) do
    ~H"""
    <form phx-submit="save_source" phx-value-id={@source_id} class="space-y-3">
      <div class="space-y-1.5">
        <.field_label for={"edit_name_#{@source_id}"}>Name</.field_label>
        <.edit_text_field
          type="text"
          id={"edit_name_#{@source_id}"}
          name="name"
          value={@edit_form.name}
        />
      </div>
      <div class="space-y-1.5">
        <.field_label for={"edit_url_#{@source_id}"}>RSS URL</.field_label>
        <.edit_text_field
          type="url"
          id={"edit_url_#{@source_id}"}
          name="url"
          value={@edit_form.url}
        />
      </div>
      <div class="space-y-1.5">
        <.field_label for={"edit_description_#{@source_id}"}>Description</.field_label>
        <textarea
          id={"edit_description_#{@source_id}"}
          name="description"
          rows="2"
          class="w-full px-3 py-2 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none resize-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
        ><%= @edit_form.description %></textarea>
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

  attr :type, :string, required: true
  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :value, :string, required: true

  defp edit_text_field(assigns) do
    ~H"""
    <input
      type={@type}
      id={@id}
      name={@name}
      value={@value}
      required
      class="w-full px-3 py-2 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
    />
    """
  end
end
