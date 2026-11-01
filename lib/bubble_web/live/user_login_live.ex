defmodule BubbleWeb.UserLoginLive do
  use BubbleWeb, :live_view

  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Log in</h1>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
            >
              Sign up
            </.link>
          </p>
        </div>

        <.card>
          <form id="login_form" action={~p"/users/log_in"} method="post" phx-update="ignore">
            <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

            <div class="space-y-4">
              <div class="space-y-1.5">
                <.field_label for="user_email">Email</.field_label>
                <.text_input
                  type="email"
                  id="user_email"
                  name="user[email]"
                  value={@form[:email].value}
                  required
                />
              </div>

              <div class="space-y-1.5">
                <.field_label for="user_password">Password</.field_label>
                <.text_input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  required
                />
              </div>

              <div class="flex items-center">
                <input
                  type="checkbox"
                  id="user_remember_me"
                  name="user[remember_me]"
                  class="w-4 h-4 rounded border-gray-300 dark:border-[#3f3f46] accent-orange-400 focus:ring-orange-400 focus:ring-opacity-20"
                />
                <label
                  for="user_remember_me"
                  class="ml-2 text-[13.5px] text-gray-700 dark:text-[#a1a1aa]"
                >
                  Keep me logged in
                </label>
              </div>

              <div class="text-center">
                <.link
                  href={~p"/users/reset_password"}
                  class="text-[12px] text-gray-500 dark:text-[#71717a] hover:text-orange-400 transition-colors uppercase tracking-wider"
                >
                  Forgot your password?
                </.link>
              </div>

              <.submit_button>Log In</.submit_button>
            </div>
          </form>
        </.card>
      </main>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
