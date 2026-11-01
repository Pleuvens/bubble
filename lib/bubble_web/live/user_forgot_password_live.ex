defmodule BubbleWeb.UserForgotPasswordLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.FieldLabel

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Forgot password?</h1>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
            We'll send a password reset link to your inbox
          </p>
        </div>

        <.card>
          <form id="reset_password_form" phx-submit="send_email">
            <div class="space-y-4">
              <div class="space-y-1.5">
                <.field_label for="user_email">Email</.field_label>
                <.text_input
                  type="email"
                  id="user_email"
                  name="user[email]"
                  placeholder="your@email.com"
                  required
                />
              </div>

              <.submit_button>Send Reset Instructions</.submit_button>
            </div>
          </form>
        </.card>

        <.auth_footer_links />
      </main>
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
