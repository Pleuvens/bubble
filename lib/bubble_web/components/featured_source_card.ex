defmodule BubbleWeb.Components.FeaturedSourceCard do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.Components.ActiveToggle
  import BubbleWeb.Components.IconButton

  attr :source, :map, required: true
  attr :subscription, :any, default: nil
  attr :editing_featured_id, :any, default: nil

  def featured_source_card(assigns) do
    assigns = assign_subscription(assigns)

    ~H"""
    <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
      <div class="flex items-start justify-between gap-4">
        <div class="flex-1">
          <div class="flex items-center gap-2 mb-1">
            <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
              {@source.name}
            </span>
            <.video_badge :if={@source.content_type == :video} />
          </div>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed">
            {@source.description}
          </p>
        </div>
        <.subscribe_control
          source_url={@source.url}
          db_source={@db_source}
          user_source={@user_source}
        />
      </div>
      <.featured_url_form :if={@editing?} db_source={@db_source} user_source={@user_source} />
      <.featured_card_actions
        :if={@subscribed? and not @editing?}
        source_id={@db_source.id}
        source_name={@source.name}
      />
    </div>
    """
  end

  defp assign_subscription(%{subscription: {db_source, user_source}} = assigns) do
    assigns
    |> assign(db_source: db_source, user_source: user_source, subscribed?: true)
    |> assign(editing?: db_source.id == assigns.editing_featured_id)
  end

  defp assign_subscription(assigns) do
    assign(assigns, db_source: nil, user_source: nil, subscribed?: false, editing?: false)
  end

  defp video_badge(assigns) do
    ~H"""
    <span class="text-[11px] font-semibold uppercase tracking-wide bg-orange-50 dark:bg-orange-400/[0.14] text-orange-500 dark:text-orange-300 px-1.5 py-0.5 rounded-full">
      Video
    </span>
    """
  end

  attr :source_url, :string, required: true
  attr :db_source, :any, default: nil
  attr :user_source, :any, default: nil

  defp subscribe_control(%{db_source: nil} = assigns) do
    ~H"""
    <button
      phx-click="subscribe_featured"
      phx-value-url={@source_url}
      class="shrink-0 border border-orange-400 text-orange-400 hover:bg-orange-400 hover:text-white uppercase tracking-wider px-3 py-1.5 rounded-lg transition-all text-[12px] font-semibold"
    >
      Subscribe
    </button>
    """
  end

  defp subscribe_control(assigns) do
    ~H"""
    <.active_toggle source_id={@db_source.id} active={@user_source.is_active} />
    """
  end

  attr :db_source, :map, required: true
  attr :user_source, :map, required: true

  defp featured_url_form(assigns) do
    ~H"""
    <form phx-submit="save_featured_url" phx-value-id={@db_source.id} class="mt-4 flex gap-2">
      <input
        type="url"
        name="url"
        value={@user_source.custom_url || @db_source.url}
        placeholder="https://www.youtube.com/feeds/videos.xml?..."
        required
        class="flex-1 px-3 py-2 text-sm border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white"
      />
      <button
        type="submit"
        class="px-3 py-2 bg-orange-400 hover:bg-orange-500 text-white rounded-lg text-xs uppercase tracking-wider transition-colors"
      >
        Save
      </button>
      <button
        type="button"
        phx-click="cancel_edit_featured"
        class="px-3 py-2 border border-gray-200 dark:border-[#26262a] text-gray-600 dark:text-[#a1a1aa] rounded-lg text-xs uppercase tracking-wider hover:bg-gray-50 dark:hover:bg-[#1f1f22] transition-colors"
      >
        Cancel
      </button>
    </form>
    """
  end

  attr :source_id, :any, required: true
  attr :source_name, :string, required: true

  defp featured_card_actions(assigns) do
    ~H"""
    <div class="flex items-center justify-end gap-1 pt-3 mt-3 border-t border-gray-100 dark:border-[#1f1f22]">
      <.icon_button
        click="edit_featured"
        source_id={@source_id}
        title="Edit feed URL"
        icon={:pencil}
      />
      <.icon_button click="fetch_source" source_id={@source_id} title="Fetch now" icon={:refresh} />
      <.icon_button
        click="delete_source"
        source_id={@source_id}
        title="Unsubscribe"
        icon={:trash}
        hover_tone={:red}
        confirm={"Unsubscribe from #{@source_name}?"}
      />
    </div>
    """
  end
end
