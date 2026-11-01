defmodule BubbleWeb.Components.AddSourceModal do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.CoreComponents
  import BubbleWeb.Components.FieldLabel

  attr :modal_step, :atom, default: nil
  attr :url_input, :string, default: ""
  attr :found_source, :any, default: nil
  attr :new_source, :any, default: nil

  def add_source_modal(%{modal_step: nil} = assigns) do
    ~H""
  end

  def add_source_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-50 flex items-center justify-center px-4">
      <div class="absolute inset-0 bg-black/40" phx-click="cancel_add" />
      <div class="relative w-full max-w-[380px] bg-white dark:bg-[#141416] rounded-2xl p-6 shadow-2xl">
        <div class="flex items-center justify-between mb-5">
          <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
            {step_title(@modal_step)}
          </span>
          <.close_button />
        </div>
        <.modal_step_body
          modal_step={@modal_step}
          url_input={@url_input}
          found_source={@found_source}
          new_source={@new_source}
        />
      </div>
    </div>
    """
  end

  defp step_title(:url_input), do: "Add RSS source"
  defp step_title(:confirm_existing), do: "Subscribe to source"
  defp step_title(:new_source_form), do: "Add new source"

  defp close_button(assigns) do
    ~H"""
    <button
      phx-click="cancel_add"
      class="w-11 h-11 flex items-center justify-center text-gray-400 dark:text-[#71717a] hover:text-gray-900 dark:hover:text-white transition-colors rounded-lg hover:bg-gray-100 dark:hover:bg-[#1f1f22]"
    >
      <svg
        viewBox="0 0 24 24"
        class="w-4 h-4"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path d="M18 6 6 18M6 6l12 12" />
      </svg>
    </button>
    """
  end

  attr :modal_step, :atom, required: true
  attr :url_input, :string, required: true
  attr :found_source, :any, required: true
  attr :new_source, :any, required: true

  defp modal_step_body(%{modal_step: :url_input} = assigns) do
    ~H"""
    <form phx-submit="check_url" class="space-y-4">
      <div class="space-y-1.5">
        <.field_label for="modal_url">RSS URL</.field_label>
        <.text_input
          type="url"
          id="modal_url"
          name="url"
          value={@url_input}
          placeholder="https://example.com/rss"
          required
          class="py-2.5 text-sm"
        />
      </div>
      <div class="flex gap-2 mt-2">
        <.primary_button type="submit">Next</.primary_button>
        <.cancel_button />
      </div>
    </form>
    """
  end

  defp modal_step_body(%{modal_step: :confirm_existing} = assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="bg-gray-50 dark:bg-[#1f1f22] p-4 rounded-lg">
        <h4 class="text-[14.5px] font-semibold text-gray-900 dark:text-white mb-1">
          {@found_source.name}
        </h4>
        <p class="text-[12px] text-gray-400 dark:text-[#52525b] mb-1 break-all">
          {@found_source.url}
        </p>
        <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
          {@found_source.description || "No description"}
        </p>
      </div>
      <p class="text-[13px] text-gray-500 dark:text-[#a1a1aa] text-center">
        This source already exists. Subscribe to it?
      </p>
      <div class="flex gap-2">
        <.primary_button type="button" click="confirm_existing_source">Subscribe</.primary_button>
        <.cancel_button />
      </div>
    </div>
    """
  end

  defp modal_step_body(%{modal_step: :new_source_form} = assigns) do
    ~H"""
    <form phx-submit="add_new_source" class="space-y-4">
      <div class="space-y-1.5">
        <.field_label>RSS URL</.field_label>
        <input type="hidden" name="url" value={@new_source.url} />
        <p class="text-[13px] text-gray-500 dark:text-[#a1a1aa] bg-gray-50 dark:bg-[#1f1f22] px-3 py-2 rounded-lg break-all">
          {@new_source.url}
        </p>
      </div>
      <div class="space-y-1.5">
        <.field_label for="modal_name">Name</.field_label>
        <.text_input
          type="text"
          id="modal_name"
          name="name"
          value={@new_source.name}
          placeholder="e.g. Tech News"
          required
          class="py-2.5 text-sm"
        />
      </div>
      <div class="flex gap-2 mt-2">
        <.primary_button type="submit">Add source</.primary_button>
        <.cancel_button />
      </div>
    </form>
    """
  end

  attr :type, :string, required: true
  attr :click, :string, default: nil
  slot :inner_block, required: true

  defp primary_button(assigns) do
    ~H"""
    <button
      type={@type}
      phx-click={@click}
      class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp cancel_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="cancel_add"
      class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
    >
      Cancel
    </button>
    """
  end
end
