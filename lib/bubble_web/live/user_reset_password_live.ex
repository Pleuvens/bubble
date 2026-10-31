defmodule BubbleWeb.UserResetPasswordLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Reset password</h1>
        </div>

        <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
          <form id="reset_password_form" phx-submit="reset_password" phx-change="validate">
            <div class="space-y-4">
              <%= if @form.errors && @form.errors != [] do %>
                <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 px-4 py-3 rounded-lg text-[13.5px]">
                  Oops, something went wrong! Please check the errors below.
                </div>
              <% end %>

              <div class="space-y-1.5">
                <label
                  for="user_password"
                  class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                >
                  New Password
                </label>
                <input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  value={@form[:password].value}
                  required
                  phx-debounce="blur"
                  class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white transition"
                />
                <.field_errors field={@form[:password]} />
              </div>

              <div class="space-y-1.5">
                <label
                  for="user_password_confirmation"
                  class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                >
                  Confirm New Password
                </label>
                <input
                  type="password"
                  id="user_password_confirmation"
                  name="user[password_confirmation]"
                  value={@form[:password_confirmation].value}
                  required
                  phx-debounce="blur"
                  class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white transition"
                />
                <.field_errors field={@form[:password_confirmation]} />
              </div>

              <button
                type="submit"
                class="w-full py-3.5 rounded-lg bg-orange-400 hover:bg-orange-500 text-white uppercase text-[13px] font-bold tracking-wide transition-colors"
              >
                Reset Password
              </button>
            </div>
          </form>
        </div>

        <.auth_footer_links />
      </main>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
