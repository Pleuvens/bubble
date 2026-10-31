defmodule BubbleWeb.Components.AuthFooterLinks do
  @moduledoc false
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: BubbleWeb.Endpoint,
    router: BubbleWeb.Router,
    statics: BubbleWeb.static_paths()

  def auth_footer_links(assigns) do
    ~H"""
    <div class="text-center mt-6 space-x-2 text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
      <.link
        href={~p"/users/register"}
        class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
      >
        Register
      </.link>
      <span class="text-gray-300 dark:text-[#3f3f46]">|</span>
      <.link
        href={~p"/users/log_in"}
        class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
      >
        Log in
      </.link>
    </div>
    """
  end
end
