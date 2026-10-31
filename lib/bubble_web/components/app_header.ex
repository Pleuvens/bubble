defmodule BubbleWeb.Components.AppHeader do
  @moduledoc false
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: BubbleWeb.Endpoint,
    router: BubbleWeb.Router,
    statics: BubbleWeb.static_paths()

  import BubbleWeb.Components.DarkModeToggle

  attr :current_page, :string, default: nil
  attr :current_user, :any, default: nil

  def app_header(assigns) do
    ~H"""
    <header class="fixed top-0 left-0 right-0 z-10 bg-white/90 dark:bg-[#0a0a0c]/90 backdrop-blur-sm border-b border-gray-200 dark:border-[#26262a]">
      <div class="max-w-[480px] mx-auto px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-7">
          <span class="text-[13px] font-bold tracking-[0.14em] uppercase text-gray-900 dark:text-white">
            Bubble
          </span>
          <nav class="flex items-center gap-1">
            <.nav_link navigate={~p"/"} active={@current_page == "feed"}>Feed</.nav_link>
            <.nav_link
              :if={@current_user}
              navigate={~p"/settings"}
              active={@current_page == "settings"}
            >
              Settings
            </.nav_link>
          </nav>
        </div>
        <div class="flex items-center gap-2.5">
          <.dark_mode_toggle />
          <.auth_links current_user={@current_user} />
        </div>
      </div>
    </header>
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "px-3 py-2.5 text-[13px] font-semibold rounded-lg",
        @active && "bg-orange-50 dark:bg-orange-400/10 text-gray-900 dark:text-white",
        !@active &&
          "text-gray-500 dark:text-[#71717a] hover:text-gray-900 dark:hover:text-white transition-colors"
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  attr :current_user, :any, default: nil

  defp auth_links(%{current_user: nil} = assigns) do
    ~H"""
    <.link
      navigate={~p"/users/log_in"}
      class="text-[13px] text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors"
    >
      Log in
    </.link>
    <.link
      navigate={~p"/users/register"}
      class="text-[13px] px-3 py-1.5 bg-orange-400 hover:bg-orange-500 text-white rounded-lg font-semibold transition-colors"
    >
      Register
    </.link>
    """
  end

  defp auth_links(assigns) do
    ~H"""
    <.link
      href={~p"/users/log_out"}
      method="delete"
      class="text-[13px] text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors"
    >
      Log out
    </.link>
    """
  end
end
