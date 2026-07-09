defmodule BubbleWeb.UserRegistrationLive do
  use BubbleWeb, :live_view

  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  alias Bubble.Accounts
  alias Bubble.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <header class="fixed top-0 left-0 right-0 z-10 bg-white/90 dark:bg-[#0a0a0c]/90 backdrop-blur-sm border-b border-gray-200 dark:border-[#26262a]">
        <div class="max-w-[480px] mx-auto px-4 py-3 flex items-center justify-between">
          <span class="text-[13px] font-bold tracking-[0.14em] uppercase text-gray-900 dark:text-white">
            Bubble
          </span>
          <div class="flex items-center gap-2.5">
            <button
              id="dark-mode-toggle"
              phx-hook="DarkModeToggle"
              title="Toggle dark mode"
              class="w-[38px] h-[38px] flex items-center justify-center rounded-full border border-gray-200 dark:border-[#26262a] text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors"
            >
              <svg
                class="dark:hidden w-[15px] h-[15px]"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <circle cx="12" cy="12" r="4" /><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
              </svg>
              <svg
                class="hidden dark:block w-[15px] h-[15px]"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
              </svg>
            </button>
            <.link
              navigate={~p"/"}
              class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors rounded-full border border-gray-200 dark:border-[#26262a]"
              aria-label="Back to feed"
            >
              <svg
                viewBox="0 0 24 24"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M18 6 6 18M6 6l12 12" />
              </svg>
            </.link>
          </div>
        </div>
      </header>

      <main class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Register</h1>
          <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
            Already registered?
            <.link
              navigate={~p"/users/log_in"}
              class="text-orange-400 hover:text-orange-500 font-semibold transition-colors"
            >
              Log in
            </.link>
          </p>
        </div>

        <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
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
              <%= if @check_errors do %>
                <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 px-4 py-3 rounded-lg text-[13.5px]">
                  Oops, something went wrong! Please check the errors below.
                </div>
              <% end %>

              <div class="space-y-1.5">
                <label
                  for="user_email"
                  class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                >
                  Email
                </label>
                <input
                  type="email"
                  id="user_email"
                  name="user[email]"
                  value={@form[:email].value}
                  required
                  phx-debounce="blur"
                  class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white transition"
                />
                <%= if @form[:email].errors && @form[:email].errors != [] do %>
                  <%= for error <- @form[:email].errors do %>
                    <p class="text-red-600 dark:text-red-400 text-[12px] mt-1">
                      {BubbleWeb.CoreComponents.translate_error(error)}
                    </p>
                  <% end %>
                <% end %>
              </div>

              <div class="space-y-1.5">
                <label
                  for="user_password"
                  class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                >
                  Password
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
                <%= if @form[:password].errors && @form[:password].errors != [] do %>
                  <%= for error <- @form[:password].errors do %>
                    <p class="text-red-600 dark:text-red-400 text-[12px] mt-1">
                      {BubbleWeb.CoreComponents.translate_error(error)}
                    </p>
                  <% end %>
                <% end %>
              </div>

              <button
                type="submit"
                class="w-full py-3.5 rounded-lg bg-orange-400 hover:bg-orange-500 text-white uppercase text-[13px] font-bold tracking-wide transition-colors"
              >
                Create Account
              </button>
            </div>
          </form>
        </div>
      </main>
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
