defmodule BubbleWeb.Components.AuthHeader do
  @moduledoc false
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: BubbleWeb.Endpoint,
    router: BubbleWeb.Router,
    statics: BubbleWeb.static_paths()

  import BubbleWeb.Components.DarkModeToggle

  def auth_header(assigns) do
    ~H"""
    <header class="fixed top-0 left-0 right-0 z-10 bg-white/90 dark:bg-[#0a0a0c]/90 backdrop-blur-sm border-b border-gray-200 dark:border-[#26262a]">
      <div class="max-w-[480px] mx-auto px-4 py-3 flex items-center justify-between">
        <span class="text-[13px] font-bold tracking-[0.14em] uppercase text-gray-900 dark:text-white">
          Bubble
        </span>
        <div class="flex items-center gap-2.5">
          <.dark_mode_toggle />
          <.link
            navigate={~p"/"}
            class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors rounded-full border border-gray-200 dark:border-[#26262a]"
            aria-label="Back to feed"
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
          </.link>
        </div>
      </div>
    </header>
    """
  end
end
