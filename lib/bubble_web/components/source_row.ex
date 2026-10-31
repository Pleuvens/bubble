defmodule BubbleWeb.Components.SourceRow do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.Components.ActiveToggle
  import BubbleWeb.Components.FieldLabel
  import BubbleWeb.Components.IconButton

  alias Bubble.News.SourceOverride

  attr :source, :map, required: true
  attr :user_source, :map, required: true
  attr :editing_source_id, :any, default: nil
  attr :edit_form, :map, required: true

  def source_row(assigns) do
    assigns = assign(assigns, :editing?, assigns.editing_source_id == assigns.source.id)

    ~H"""
    <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
      <.source_edit_form :if={@editing?} source_id={@source.id} edit_form={@edit_form} />
      <.source_details :if={not @editing?} source={@source} user_source={@user_source} />
    </div>
    """
  end

  attr :source_id, :any, required: true
  attr :edit_form, :map, required: true

  defp source_edit_form(assigns) do
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

  attr :source, :map, required: true
  attr :user_source, :map, required: true

  defp source_details(assigns) do
    ~H"""
    <div>
      <div class="flex items-start justify-between gap-4 mb-3">
        <div class="flex-1 min-w-0">
          <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
            {SourceOverride.name(@source, @user_source)}
          </span>
          <p class="text-[12px] text-gray-400 dark:text-[#52525b] mt-0.5 break-all">
            {SourceOverride.url(@source, @user_source)}
          </p>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed mt-1">
            {SourceOverride.description(@source, @user_source) || "No description"}
          </p>
        </div>
        <.active_toggle source_id={@source.id} active={@user_source.is_active} />
      </div>
      <div class="flex items-center justify-between pt-3 border-t border-gray-100 dark:border-[#1f1f22]">
        <p class="text-[12px] text-gray-400 dark:text-[#52525b]">
          Subscribed {Calendar.strftime(@user_source.inserted_at, "%b %d, %Y")}
        </p>
        <div class="flex gap-1">
          <.icon_button
            click="edit_source"
            source_id={@source.id}
            title="Edit source"
            icon={:pencil}
          />
          <.icon_button
            click="fetch_source"
            source_id={@source.id}
            title="Fetch now"
            icon={:refresh}
          />
          <.icon_button
            click="delete_source"
            source_id={@source.id}
            title="Unsubscribe"
            icon={:trash}
            hover_tone={:red}
            confirm="Are you sure you want to unsubscribe from this RSS source?"
          />
        </div>
      </div>
    </div>
    """
  end
end
