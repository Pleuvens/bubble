defmodule BubbleWeb.UserLoginLive do
  use BubbleWeb, :live_view

  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-16 px-4">
      <div class="w-full max-w-md">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light mb-4">
            Log In
          </h1>
          <p class="text-sm text-gray-600">
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
            >
              Sign up
            </.link>
          </p>
        </div>
        
    <!-- Form Card -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <form id="login_form" action={~p"/users/log_in"} method="post" phx-update="ignore">
            <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

            <div class="space-y-4">
              <!-- Email Input -->
              <div class="space-y-2">
                <label for="user_email" class="text-xs uppercase tracking-wider text-gray-600">
                  Email
                </label>
                <input
                  type="email"
                  id="user_email"
                  name="user[email]"
                  value={@form[:email].value}
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
              </div>
              
    <!-- Password Input -->
              <div class="space-y-2">
                <label for="user_password" class="text-xs uppercase tracking-wider text-gray-600">
                  Password
                </label>
                <input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
              </div>
              
    <!-- Remember Me Checkbox -->
              <div class="flex items-center">
                <input
                  type="checkbox"
                  id="user_remember_me"
                  name="user[remember_me]"
                  class="w-4 h-4 text-orange-400 border-gray-300 rounded focus:ring-orange-400 focus:ring-opacity-20"
                />
                <label for="user_remember_me" class="ml-2 text-sm text-gray-700">
                  Keep me logged in
                </label>
              </div>
              
    <!-- Forgot Password Link -->
              <div class="text-center">
                <.link
                  href={~p"/users/reset_password"}
                  class="text-xs text-gray-600 hover:text-orange-400 transition-colors uppercase tracking-wider"
                >
                  Forgot your password?
                </.link>
              </div>
              
    <!-- Submit Button -->
              <button
                type="submit"
                class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
              >
                Log In
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
