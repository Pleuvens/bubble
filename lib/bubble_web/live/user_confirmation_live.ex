defmodule BubbleWeb.UserConfirmationLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-16 px-4">
      <div class="w-full max-w-md">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light mb-4">
            Confirm Account
          </h1>
        </div>
        
    <!-- Form Card -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <form id="confirmation_form" phx-submit="confirm_account">
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />

            <div class="space-y-4">
              <p class="text-sm text-gray-600 text-center mb-4">
                Click the button below to confirm your account.
              </p>
              
    <!-- Submit Button -->
              <button
                type="submit"
                class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
              >
                Confirm My Account
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
