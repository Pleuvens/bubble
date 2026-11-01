defmodule BubbleWeb.CoreComponents do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: BubbleWeb.Gettext

  alias Phoenix.LiveView.JS

  attr :id, :string
  attr :flash, :map, default: %{}
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error]
  attr :rest, :global

  slot :inner_block

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :class, :string, default: "text-red-600 dark:text-red-400 text-xs mt-1"

  def field_errors(assigns) do
    ~H"""
    <p :for={error <- @field.errors} class={@class}>{translate_error(error)}</p>
    """
  end

  attr :type, :string, required: true
  attr :name, :string, required: true
  attr :id, :string, default: nil
  attr :value, :any, default: nil
  attr :class, :string, default: "py-2.5"
  attr :rest, :global, include: ~w(placeholder required)

  def text_input(assigns) do
    ~H"""
    <input
      type={@type}
      id={@id}
      name={@name}
      value={@value}
      class={[field_classes(), @class]}
      {@rest}
    />
    """
  end

  attr :name, :string, required: true
  attr :id, :string, default: nil
  attr :value, :any, default: nil
  attr :class, :string, default: "py-2 text-sm resize-none"
  attr :rest, :global, include: ~w(placeholder required rows)

  def text_area(assigns) do
    ~H"""
    <textarea id={@id} name={@name} class={[field_classes(), @class]} {@rest}>{@value}</textarea>
    """
  end

  slot :inner_block, required: true

  def submit_button(assigns) do
    ~H"""
    <button
      type="submit"
      class="w-full py-3.5 rounded-lg bg-orange-400 hover:bg-orange-500 text-white uppercase text-[13px] font-bold tracking-wide transition-colors"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp field_classes do
    "w-full px-3 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white transition"
  end

  attr :error, :any, required: true
  attr :class, :string, default: "text-red-600 dark:text-red-400 text-xs mt-1"

  def form_error(assigns) do
    ~H"""
    <p :if={@error} class={@class}>{translate_error(@error)}</p>
    """
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(BubbleWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BubbleWeb.Gettext, "errors", msg, opts)
    end
  end
end
