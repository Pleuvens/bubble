defmodule BubbleWeb.UserSettingsLive do
  use BubbleWeb, :live_view

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-16">
      <!-- Header -->
      <div class="fixed top-0 left-0 right-0 z-10 bg-white/80 backdrop-blur-sm border-b border-gray-200">
        <div class="flex items-center justify-between px-6 py-4">
          <h1 class="text-sm uppercase tracking-wider text-gray-600">Account Settings</h1>
          <.link
            navigate={~p"/"}
            class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors px-4 py-2 rounded-md hover:bg-gray-100"
          >
            <span class="inline-block mr-2">✕</span> Close
          </.link>
        </div>
      </div>

      <div class="max-w-2xl mx-auto px-8 mt-8">
        <!-- Change Email Section -->
        <div class="mb-12">
          <h2 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light text-center mb-8">
            Change Email
          </h2>

          <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
            <form id="email_form" phx-submit="update_email" phx-change="validate_email">
              <div class="space-y-4">
                <!-- Email Input -->
                <div class="space-y-2">
                  <label for="user_email" class="text-xs uppercase tracking-wider text-gray-600">
                    New Email
                  </label>
                  <input
                    type="email"
                    id="user_email"
                    name="user[email]"
                    value={@email_form[:email].value}
                    required
                    phx-debounce="blur"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                  <%= if @email_form[:email].errors && @email_form[:email].errors != [] do %>
                    <%= for error <- @email_form[:email].errors do %>
                      <p class="text-red-600 text-xs mt-1">{elem(error, 0)}</p>
                    <% end %>
                  <% end %>
                </div>
                
    <!-- Current Password Input -->
                <div class="space-y-2">
                  <label
                    for="current_password_for_email"
                    class="text-xs uppercase tracking-wider text-gray-600"
                  >
                    Current Password
                  </label>
                  <input
                    type="password"
                    id="current_password_for_email"
                    name="current_password"
                    value={@email_form_current_password}
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                </div>
                
    <!-- Submit Button -->
                <button
                  type="submit"
                  class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                >
                  Change Email
                </button>
              </div>
            </form>
          </div>
        </div>
        
    <!-- Change Password Section -->
        <div>
          <h2 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light text-center mb-8">
            Change Password
          </h2>

          <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
            <form
              id="password_form"
              action={~p"/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />

              <div class="space-y-4">
                <!-- New Password Input -->
                <div class="space-y-2">
                  <label for="user_password" class="text-xs uppercase tracking-wider text-gray-600">
                    New Password
                  </label>
                  <input
                    type="password"
                    id="user_password"
                    name="user[password]"
                    value={@password_form[:password].value}
                    required
                    phx-debounce="blur"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                  <%= if @password_form[:password].errors && @password_form[:password].errors != [] do %>
                    <%= for error <- @password_form[:password].errors do %>
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
                    value={@password_form[:password_confirmation].value}
                    phx-debounce="blur"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                  <%= if @password_form[:password_confirmation].errors &&
                        @password_form[:password_confirmation].errors != [] do %>
                    <%= for error <- @password_form[:password_confirmation].errors do %>
                      <p class="text-red-600 text-xs mt-1">{elem(error, 0)}</p>
                    <% end %>
                  <% end %>
                </div>
                
    <!-- Current Password Input -->
                <div class="space-y-2">
                  <label
                    for="current_password_for_password"
                    class="text-xs uppercase tracking-wider text-gray-600"
                  >
                    Current Password
                  </label>
                  <input
                    type="password"
                    id="current_password_for_password"
                    name="current_password"
                    value={@current_password}
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                </div>
                
    <!-- Submit Button -->
                <button
                  type="submit"
                  class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                >
                  Change Password
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
