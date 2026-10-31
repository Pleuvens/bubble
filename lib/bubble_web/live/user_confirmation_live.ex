defmodule BubbleWeb.UserConfirmationLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Confirm account</h1>
        </div>

        <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
          <form id="confirmation_form" phx-submit="confirm_account">
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />

            <div class="space-y-4">
              <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] text-center">
                Click the button below to confirm your account.
              </p>

              <button
                type="submit"
                class="w-full py-3.5 rounded-lg bg-orange-400 hover:bg-orange-500 text-white uppercase text-[13px] font-bold tracking-wide transition-colors"
              >
                Confirm My Account
              </button>
            </div>
          </form>
        </div>

        <.auth_footer_links />
      </main>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
