defmodule BubbleWeb.Components.DarkModeToggle do
  @moduledoc false
  use Phoenix.Component

  def dark_mode_toggle(assigns) do
    ~H"""
    <button
      id="dark-mode-toggle"
      phx-hook="DarkModeToggle"
      title="Toggle dark mode"
      class="w-[38px] h-[38px] flex items-center justify-center rounded-full border border-gray-200 dark:border-[#26262a] text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors"
    >
      <svg
        class="dark:hidden w-[15px] h-[15px]"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <circle cx="12" cy="12" r="4" /><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
      </svg>
      <svg
        class="hidden dark:block w-[15px] h-[15px]"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
      </svg>
    </button>
    """
  end
end
