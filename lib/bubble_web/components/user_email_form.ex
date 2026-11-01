defmodule BubbleWeb.Components.UserEmailForm do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.CoreComponents
  import BubbleWeb.Components.SettingsField

  attr :email_form, :any, required: true
  attr :current_password, :any, default: nil

  def user_email_form(assigns) do
    ~H"""
    <form id="email_form" phx-submit="update_email" phx-change="validate_email">
      <div class="space-y-4">
        <.settings_field
          id="user_email"
          name="user[email]"
          type="email"
          label="New Email"
          value={@email_form[:email].value}
          debounce
        >
          <:error><.field_errors field={@email_form[:email]} /></:error>
        </.settings_field>

        <.settings_field
          id="current_password_for_email"
          name="current_password"
          type="password"
          label="Current Password"
          value={@current_password}
        >
          <:error><.form_error error={@email_form.errors[:current_password]} /></:error>
        </.settings_field>

        <.submit_button>Change Email</.submit_button>
      </div>
    </form>
    """
  end
end
