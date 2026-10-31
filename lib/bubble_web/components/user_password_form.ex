defmodule BubbleWeb.Components.UserPasswordForm do
  @moduledoc false
  use Phoenix.Component

  import BubbleWeb.CoreComponents
  import BubbleWeb.Components.SettingsField

  attr :password_form, :any, required: true
  attr :current_email, :string, required: true
  attr :current_password, :any, default: nil
  attr :trigger_submit, :boolean, required: true
  attr :log_in_action, :string, required: true

  def user_password_form(assigns) do
    ~H"""
    <form
      id="password_form"
      action={@log_in_action}
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
        <.settings_field
          id="user_password"
          name="user[password]"
          type="password"
          label="New Password"
          value={@password_form[:password].value}
          debounce
        >
          <:error><.field_errors field={@password_form[:password]} /></:error>
        </.settings_field>

        <.settings_field
          id="user_password_confirmation"
          name="user[password_confirmation]"
          type="password"
          label="Confirm New Password"
          value={@password_form[:password_confirmation].value}
          required={false}
          debounce
        >
          <:error><.field_errors field={@password_form[:password_confirmation]} /></:error>
        </.settings_field>

        <.settings_field
          id="current_password_for_password"
          name="current_password"
          type="password"
          label="Current Password"
          value={@current_password}
        >
          <:error><.form_error error={@password_form.errors[:current_password]} /></:error>
        </.settings_field>

        <.settings_submit_button>Change Password</.settings_submit_button>
      </div>
    </form>
    """
  end
end
