defmodule BubbleWeb.UserConfirmationInstructionsLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.FieldLabel

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Resend confirmation</h1>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
            We'll send a new confirmation link to your inbox
          </p>
        </div>

        <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
          <form id="resend_confirmation_form" phx-submit="send_instructions">
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

              <.submit_button>Resend Confirmation Instructions</.submit_button>
            </div>
          </form>
        </div>

        <.auth_footer_links />
      </main>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
