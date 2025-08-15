defmodule BubbleWeb.SettingsLive do
  use BubbleWeb, :live_view

  alias Bubble.Sources

  def render(assigns) do
    ~H"""
    <div class="settings">
      <h1>Settings</h1>
      <p>Welcome to the settings page!</p>
      <%= for source <- @sources do %>
        <div class="source">
          <h2>{source.name}</h2>
          <p>{source.url}</p>
          <button phx-click="remove_source" phx-value-id={source.id}>Remove</button>
        </div>
      <% end %>
      <form phx-submit="add_source">
        <div class="form-group">
          <label for="name">Name:</label>
          <input type="text" id="name" name="name" value={@name} />
        </div>
        <div class="form-group">
          <label for="url">URL:</label>
          <input type="text" id="url" name="url" value={@url} />
        </div>
        <button type="submit">Add source</button>
      </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    sources = Sources.list_sources()

    {:ok,
     socket
     |> assign(:sources, sources)
     |> assign(:name, "")
     |> assign(:url, "")}
  end

  def handle_event("remove_source", %{"id" => id}, socket) do
    case Sources.delete_source(id) do
      {1, _} ->
        {:noreply, assign(socket, :sources, Sources.list_sources())}

      {0, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to remove source.")}
    end
  end

  def handle_event("add_source", %{"name" => name, "url" => url}, socket) do
    case Sources.add_source(%{name: name, url: url}) do
      {:ok, _source} ->
        {:noreply,
         assign(socket, :sources, Sources.list_sources())
         |> put_flash(:info, "Source added successfully.")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Failed to add source.")}
    end
  end
end
