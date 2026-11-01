defmodule BubbleWeb.UserResetPasswordLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.FieldLabel

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Reset password</h1>
        </div>

        <.card>
          <form id="reset_password_form" phx-submit="reset_password" phx-change="validate">
            <div class="space-y-4">
              <.form_errors_banner :if={@form.errors != []} />

              <div class="space-y-1.5">
                <.field_label for="user_password">New Password</.field_label>
                <.text_input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  value={@form[:password].value}
                  required
                  phx-debounce="blur"
                />
                <.field_errors field={@form[:password]} />
              </div>

              <div class="space-y-1.5">
                <.field_label for="user_password_confirmation">Confirm New Password</.field_label>
                <.text_input
                  type="password"
                  id="user_password_confirmation"
                  name="user[password_confirmation]"
                  value={@form[:password_confirmation].value}
                  required
                  phx-debounce="blur"
                />
                <.field_errors field={@form[:password_confirmation]} />
              </div>

              <.submit_button>Reset Password</.submit_button>
            </div>
          </form>
        </.card>

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
