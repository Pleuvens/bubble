defmodule BubbleWeb.UserRegistrationLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.FieldLabel
  import Plug.CSRFProtection, only: [get_csrf_token: 0]

  alias Bubble.Accounts
  alias Bubble.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.auth_header />

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

        <.card>
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
                <.field_label for="user_email">Email</.field_label>
                <.text_input
                  type="email"
                  id="user_email"
                  name="user[email]"
                  value={@form[:email].value}
                  required
                  phx-debounce="blur"
                />
                <.field_errors
                  field={@form[:email]}
                  class="text-red-600 dark:text-red-400 text-[12px] mt-1"
                />
              </div>

              <div class="space-y-1.5">
                <.field_label for="user_password">Password</.field_label>
                <.text_input
                  type="password"
                  id="user_password"
                  name="user[password]"
                  value={@form[:password].value}
                  required
                  phx-debounce="blur"
                />
                <.field_errors
                  field={@form[:password]}
                  class="text-red-600 dark:text-red-400 text-[12px] mt-1"
                />
              </div>

              <.submit_button>Create Account</.submit_button>
            </div>
          </form>
        </.card>
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
