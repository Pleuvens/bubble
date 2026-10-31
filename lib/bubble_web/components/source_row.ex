defmodule BubbleWeb.Components.SourceRow do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.Components.ActiveToggle
  import BubbleWeb.Components.IconButton
  import BubbleWeb.Components.SourceEditForm

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
