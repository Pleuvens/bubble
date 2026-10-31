defmodule BubbleWeb.UserSettingsLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.UserEmailForm
  import BubbleWeb.Components.UserPasswordForm

  alias Bubble.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.app_header current_user={@current_user} />

      <div class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <.settings_section title="Change email" class="mb-10">
          <.user_email_form
            email_form={@email_form}
            current_password={@email_form_current_password}
          />
        </.settings_section>

        <.settings_section title="Change password">
          <.user_password_form
            password_form={@password_form}
            current_email={@current_email}
            current_password={@current_password}
            trigger_submit={@trigger_submit}
            log_in_action={~p"/users/log_in?_action=password_updated"}
          />
        </.settings_section>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  defp settings_section(assigns) do
    ~H"""
    <section {@rest}>
      <h2 class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a] mb-4">
        {@title}
      </h2>

      <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
        {render_slot(@inner_block)}
      </div>
    </section>
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
