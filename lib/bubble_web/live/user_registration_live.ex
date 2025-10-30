defmodule BubbleWeb.UserRegistrationLive do
  use BubbleWeb, :live_view

  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  alias Bubble.Accounts
  alias Bubble.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-16 px-4">
      <div class="w-full max-w-md">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light mb-4">
            Register
          </h1>
          <p class="text-sm text-gray-600">
            Already registered?
            <.link
              navigate={~p"/users/log_in"}
              class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
            >
              Log in
            </.link>
          </p>
        </div>
        
    <!-- Form Card -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <form
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
          >
            <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

            <div class="space-y-4">
              <!-- Error Message -->
              <%= if @check_errors do %>
                <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md text-sm">
                  Oops, something went wrong! Please check the errors below.
                </div>
              <% end %>
              
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
                  phx-debounce="blur"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                />
                <%= if @form[:email].errors && @form[:email].errors != [] do %>
                  <%= for error <- @form[:email].errors do %>
                    <p class="text-red-600 text-xs mt-1">{elem(error, 0)}</p>
                  <% end %>
                <% end %>
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
              
    <!-- Submit Button -->
              <button
                type="submit"
                class="w-full bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
              >
                Create Account
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
