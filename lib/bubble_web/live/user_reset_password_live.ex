defmodule BubbleWeb.UserResetPasswordLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-16 px-4">
      <div class="w-full max-w-md">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light mb-4">
            Reset Password
          </h1>
        </div>
        
    <!-- Form Card -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <form id="reset_password_form" phx-submit="reset_password" phx-change="validate">
            <div class="space-y-4">
              <!-- Error Message -->
              <%= if @form.errors && @form.errors != [] do %>
                <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md text-sm">
                  Oops, something went wrong! Please check the errors below.
                </div>
              <% end %>
              
    <!-- New Password Input -->
              <div class="space-y-2">
                <label for="user_password" class="text-xs uppercase tracking-wider text-gray-600">
                  New Password
                </label>
                <input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  value={@form[:password].value}
                  required
                  phx-debounce="blur"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
                <%= if @form[:password].errors && @form[:password].errors != [] do %>
                  <%= for error <- @form[:password].errors do %>
                    <p class="text-red-600 text-xs mt-1">{elem(error, 0)}</p>
                  <% end %>
                <% end %>
              </div>
              
    <!-- Confirm Password Input -->
              <div class="space-y-2">
                <label
                  for="user_password_confirmation"
                  class="text-xs uppercase tracking-wider text-gray-600"
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
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
                <%= if @form[:password_confirmation].errors && @form[:password_confirmation].errors != [] do %>
                  <%= for error <- @form[:password_confirmation].errors do %>
                    <p class="text-red-600 text-xs mt-1">{elem(error, 0)}</p>
                  <% end %>
                <% end %>
              </div>
              
    <!-- Submit Button -->
              <button
                type="submit"
                class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
              >
                Reset Password
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
