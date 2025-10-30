defmodule BubbleWeb.UserForgotPasswordLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-16 px-4">
      <div class="w-full max-w-md">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light mb-4">
            Forgot Password?
          </h1>
          <p class="text-sm text-gray-600">
            We'll send a password reset link to your inbox
          </p>
        </div>
        
    <!-- Form Card -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <form id="reset_password_form" phx-submit="send_email">
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
                  placeholder="your@email.com"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
              </div>
              
    <!-- Submit Button -->
              <button
                type="submit"
                class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
              >
                Send Reset Instructions
              </button>
            </div>
          </form>
        </div>
        
    <!-- Links -->
        <div class="text-center mt-6 space-x-2 text-sm text-gray-600">
          <.link
            href={~p"/users/register"}
            class="text-orange-400 hover:text-orange-500 transition-colors"
          >
            Register
          </.link>
          <span>|</span>
          <.link
            href={~p"/users/log_in"}
            class="text-orange-400 hover:text-orange-500 transition-colors"
          >
            Log in
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
