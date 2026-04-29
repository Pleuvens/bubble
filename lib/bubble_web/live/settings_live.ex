defmodule BubbleWeb.SettingsLive do
  use BubbleWeb, :live_view

  on_mount {BubbleWeb.UserAuth, :mount_current_user}

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.NewsSources

  @featured_sources [
    %{
      name: "NBA Game Recaps",
      url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCWJ2lWNubArHWmf3FIHbfcQ",
      description: "Official NBA YouTube channel — game recaps and last night's summaries.",
      content_type: :video
    }
  ]

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-16">
      <!-- Header -->
      <div class="fixed top-0 left-0 right-0 z-10 bg-white/80 backdrop-blur-sm border-b border-gray-200">
        <div class="flex items-center justify-between px-6 py-4">
          <h1 class="text-sm uppercase tracking-wider text-gray-600">Settings</h1>
          <.link
            navigate={~p"/"}
            class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors px-4 py-2 rounded-md hover:bg-gray-100"
          >
            <span class="inline-block mr-2">✕</span> Close
          </.link>
        </div>
      </div>

      <div class="max-w-4xl mx-auto px-8">
        <!-- Featured Sources Section -->
        <div class="mb-12">
          <h2 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light text-center mb-2 mt-8">
            Discover
          </h2>
          <p class="text-center text-xs text-gray-500 uppercase tracking-widest mb-8">
            Curated sources — subscribe with one click
          </p>
          <div class="max-w-2xl mx-auto space-y-4">
            <%= for source <- @featured_sources do %>
              <% sub = Map.get(@featured_subscriptions, source.name) %>
              <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
                <div class="flex items-start justify-between gap-4">
                  <div class="flex-1">
                    <div class="flex items-center gap-2 mb-1">
                      <h3 class="text-orange-400 uppercase tracking-wide">{source.name}</h3>
                      <%= if source.content_type == :video do %>
                        <span class="text-xs uppercase tracking-wider bg-orange-100 text-orange-500 px-2 py-0.5 rounded">
                          Video
                        </span>
                      <% end %>
                    </div>
                    <p class="text-sm text-gray-600">{source.description}</p>
                  </div>
                  <%= if sub do %>
                    <% {db_source, user_source} = sub %>
                    <button
                      phx-click="toggle_active"
                      phx-value-id={db_source.id}
                      class={
                        "shrink-0 relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2 #{if user_source.is_active, do: "bg-orange-400", else: "bg-gray-200"}"
                      }
                    >
                      <span class={
                        "inline-block h-4 w-4 transform rounded-full bg-white transition-transform #{if user_source.is_active, do: "translate-x-6", else: "translate-x-1"}"
                      }>
                      </span>
                    </button>
                  <% else %>
                    <button
                      phx-click="subscribe_featured"
                      phx-value-url={source.url}
                      class="shrink-0 border border-orange-400 text-orange-400 hover:bg-orange-400 hover:text-white uppercase tracking-wider px-4 py-2 rounded-md transition-all text-xs"
                    >
                      Subscribe
                    </button>
                  <% end %>
                </div>
                <%!-- Edit URL form --%>
                <%= if sub && elem(sub, 0).id == @editing_featured_id do %>
                  <% {db_source, db_user_source} = sub %>
                  <form phx-submit="save_featured_url" phx-value-id={db_source.id} class="mt-4 flex gap-2">
                    <input
                      type="url"
                      name="url"
                      value={db_user_source.custom_url || db_source.url}
                      placeholder="https://www.youtube.com/feeds/videos.xml?..."
                      required
                      class="flex-1 px-3 py-2 text-sm border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none"
                    />
                    <button type="submit" class="px-3 py-2 bg-orange-400 hover:bg-orange-500 text-white rounded-md text-xs uppercase tracking-wider transition-colors">
                      Save
                    </button>
                    <button type="button" phx-click="cancel_edit_featured" class="px-3 py-2 border border-gray-300 text-gray-600 rounded-md text-xs uppercase tracking-wider hover:bg-gray-50 transition-colors">
                      Cancel
                    </button>
                  </form>
                <% end %>
                <%!-- Controls row (only when subscribed and not editing) --%>
                <%= if sub && elem(sub, 0).id != @editing_featured_id do %>
                  <% {db_source, _} = sub %>
                  <div class="flex items-center justify-end gap-1 pt-3 mt-3 border-t border-gray-100">
                    <button
                      phx-click="edit_featured"
                      phx-value-id={db_source.id}
                      title="Edit feed URL"
                      class="text-gray-500 hover:text-orange-400 transition-colors p-2 rounded-md hover:bg-gray-50"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
                      </svg>
                    </button>
                    <button
                      phx-click="fetch_source"
                      phx-value-id={db_source.id}
                      title="Fetch now"
                      class="text-gray-500 hover:text-orange-400 transition-colors p-2 rounded-md hover:bg-gray-50"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" />
                      </svg>
                    </button>
                    <button
                      phx-click="delete_source"
                      phx-value-id={db_source.id}
                      data-confirm={"Unsubscribe from #{source.name}?"}
                      title="Unsubscribe"
                      class="text-gray-500 hover:text-red-500 transition-colors p-2 rounded-md hover:bg-gray-50"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
                      </svg>
                    </button>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
        <!-- RSS Sources Section -->
        <div>
          <!-- Section title -->
          <h2 class="text-3xl md:text-4xl text-orange-400 tracking-wide uppercase font-light text-center mb-8 mt-8">
            RSS Sources
          </h2>
          <!-- Add new source button -->
          <div class="text-center mb-8">
            <button
              phx-click="show_add_form"
              class="border border-orange-400 text-orange-400 hover:bg-orange-400 hover:text-white uppercase tracking-wider px-4 py-2 rounded-md transition-all"
            >
              <span class="inline-block mr-2">+</span> Add RSS Source
            </button>
          </div>
          <!-- Step 1: URL Input -->
          <%= if @modal_step == :url_input do %>
            <div class="max-w-md mx-auto mb-8 p-6 bg-white rounded-lg border border-gray-200 shadow-sm">
              <h3 class="text-sm uppercase tracking-wider text-gray-600 mb-4 text-center">
                Enter RSS URL
              </h3>
              <form phx-submit="check_url" class="space-y-4">
                <div class="space-y-2">
                  <label for="url" class="text-xs uppercase tracking-wider text-gray-600">
                    RSS URL
                  </label>
                  <input
                    type="url"
                    id="url"
                    name="url"
                    value={@url_input}
                    placeholder="https://example.com/rss"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                </div>
                <div class="flex gap-2">
                  <button
                    type="submit"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Next
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          <% end %>
          <!-- Step 2a: Confirm Existing Source -->
          <%= if @modal_step == :confirm_existing do %>
            <div class="max-w-md mx-auto mb-8 p-6 bg-white rounded-lg border border-gray-200 shadow-sm">
              <h3 class="text-sm uppercase tracking-wider text-gray-600 mb-4 text-center">
                Subscribe to Existing Source
              </h3>
              <div class="space-y-4">
                <div class="bg-gray-50 p-4 rounded-md">
                  <h4 class="text-orange-400 uppercase tracking-wide mb-2">
                    {@found_source.name}
                  </h4>
                  <p class="text-xs text-gray-600 mb-2 break-all">{@found_source.url}</p>
                  <p class="text-sm text-gray-700">
                    {@found_source.description || "No description"}
                  </p>
                </div>
                <p class="text-xs text-gray-600 text-center">
                  This RSS source already exists. Would you like to subscribe to it?
                </p>
                <div class="flex gap-2">
                  <button
                    type="button"
                    phx-click="confirm_existing_source"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Subscribe
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          <% end %>
          <!-- Step 2b: New Source Form -->
          <%= if @modal_step == :new_source_form do %>
            <div class="max-w-md mx-auto mb-8 p-6 bg-white rounded-lg border border-gray-200 shadow-sm">
              <h3 class="text-sm uppercase tracking-wider text-gray-600 mb-4 text-center">
                Add New Source
              </h3>
              <form phx-submit="add_new_source" class="space-y-4">
                <div class="space-y-2">
                  <label class="text-xs uppercase tracking-wider text-gray-600">RSS URL</label>
                  <input type="hidden" name="url" value={@new_source.url} />
                  <p class="text-sm text-gray-700 bg-gray-50 px-3 py-2 rounded-md break-all">
                    {@new_source.url}
                  </p>
                </div>
                <div class="space-y-2">
                  <label for="name" class="text-xs uppercase tracking-wider text-gray-600">
                    Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    value={@new_source.name}
                    placeholder="e.g. Tech News"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                  />
                </div>
                <div class="space-y-2">
                  <label for="description" class="text-xs uppercase tracking-wider text-gray-600">
                    Description
                  </label>
                  <textarea
                    id="description"
                    name="description"
                    placeholder="Brief description of this source"
                    rows="2"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none resize-none transition"
                  ><%= @new_source.description %></textarea>
                </div>
                <div class="flex gap-2">
                  <button
                    type="submit"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Add Source
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          <% end %>
          <!-- RSS sources list -->
          <div class="max-w-2xl mx-auto space-y-4">
            <%= for {source, user_source} <- @sources do %>
              <div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm hover:shadow-md transition-shadow">
                <%= if @editing_source_id == source.id do %>
                  <!-- Edit mode -->
                  <form phx-submit="save_source" phx-value-id={source.id} class="space-y-4">
                    <div class="space-y-2">
                      <label
                        for={"edit_name_#{source.id}"}
                        class="text-xs uppercase tracking-wider text-gray-600"
                      >
                        Name
                      </label>
                      <input
                        type="text"
                        id={"edit_name_#{source.id}"}
                        name="name"
                        value={@edit_form.name}
                        required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                      />
                    </div>
                    <div class="space-y-2">
                      <label
                        for={"edit_url_#{source.id}"}
                        class="text-xs uppercase tracking-wider text-gray-600"
                      >
                        RSS URL
                      </label>
                      <input
                        type="url"
                        id={"edit_url_#{source.id}"}
                        name="url"
                        value={@edit_form.url}
                        required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none transition"
                      />
                    </div>
                    <div class="space-y-2">
                      <label
                        for={"edit_description_#{source.id}"}
                        class="text-xs uppercase tracking-wider text-gray-600"
                      >
                        Description
                      </label>
                      <textarea
                        id={"edit_description_#{source.id}"}
                        name="description"
                        rows="2"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none resize-none transition"
                      ><%= @edit_form.description %></textarea>
                    </div>
                    <div class="flex gap-2">
                      <button
                        type="submit"
                        class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                      >
                        Save
                      </button>
                      <button
                        type="button"
                        phx-click="cancel_edit"
                        class="flex-1 border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-md uppercase tracking-wider transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  </form>
                <% else %>
                  <!-- Display mode -->
                  <div>
                    <div class="flex items-start justify-between mb-2">
                      <div class="flex-1">
                        <h3 class="text-orange-400 uppercase tracking-wide mb-1">{source.name}</h3>
                        <p class="text-xs text-gray-600 mb-2 break-all">{source.url}</p>
                        <p class="text-sm text-gray-700">{source.description || "No description"}</p>
                      </div>
                      <div class="flex items-center gap-2 ml-4">
                        <button
                          phx-click="toggle_active"
                          phx-value-id={source.id}
                          class={
                            "relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2 #{if user_source.is_active, do: "bg-orange-400", else: "bg-gray-200"}"
                          }
                        >
                          <span class={
                            "inline-block h-4 w-4 transform rounded-full bg-white transition-transform #{if user_source.is_active, do: "translate-x-6", else: "translate-x-1"}"
                          }>
                          </span>
                        </button>
                      </div>
                    </div>
                    <div class="flex items-center justify-between pt-3 border-t border-gray-100">
                      <p class="text-xs text-gray-500 uppercase tracking-wider">
                        Subscribed {Calendar.strftime(user_source.inserted_at, "%b %d, %Y")}
                      </p>
                      <div class="flex gap-2">
                        <button
                          phx-click="edit_source"
                          phx-value-id={source.id}
                          title="Edit source"
                          class="text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-md hover:bg-gray-50"
                        >
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="w-4 h-4"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                          >
                            <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
                          </svg>
                        </button>
                        <button
                          phx-click="fetch_source"
                          phx-value-id={source.id}
                          title="Fetch now"
                          class="text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-md hover:bg-gray-50"
                        >
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="w-4 h-4"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                          >
                            <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8" />
                            <path d="M21 3v5h-5" />
                          </svg>
                        </button>
                        <button
                          phx-click="delete_source"
                          phx-value-id={source.id}
                          data-confirm="Are you sure you want to unsubscribe from this RSS source?"
                          title="Unsubscribe"
                          class="text-gray-600 hover:text-red-500 transition-colors p-2 rounded-md hover:bg-gray-50"
                        >
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="w-4 h-4"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                          >
                            <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    {:ok,
     socket
     |> assign_sources(user_id)
     |> assign(:featured_sources, @featured_sources)
     |> assign(:editing_featured_id, nil)
     |> assign(:modal_step, nil)
     |> assign(:editing_source_id, nil)
     |> assign(:url_input, "")
     |> assign(:found_source, nil)
     |> assign(:new_source, %{name: "", url: "", description: ""})
     |> assign(:edit_form, %{name: "", url: "", description: ""})}
  end

  def handle_event("show_add_form", _params, socket) do
    {:noreply, assign(socket, :modal_step, :url_input)}
  end

  def handle_event("cancel_add", _params, socket) do
    {:noreply,
     socket
     |> assign(:modal_step, nil)
     |> assign(:url_input, "")
     |> assign(:found_source, nil)
     |> assign(:new_source, %{name: "", url: "", description: ""})}
  end

  def handle_event("subscribe_featured", %{"url" => url}, socket) do
    user_id = socket.assigns.current_user.id
    attrs = Enum.find(@featured_sources, &(&1.url == url))

    result =
      case NewsSources.get_featured_source_by_name(attrs.name) do
        nil ->
          NewsSources.create_and_add_user_source(user_id, Map.put(attrs, :is_featured, true))

        existing ->
          NewsSources.add_user_source(user_id, existing.id)
      end

    case result do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> put_flash(:info, "Subscribed to #{attrs.name}.")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to subscribe.")}
    end
  end

  def handle_event("edit_featured", %{"id" => id}, socket) do
    {:noreply, assign(socket, :editing_featured_id, id)}
  end

  def handle_event("cancel_edit_featured", _params, socket) do
    {:noreply, assign(socket, :editing_featured_id, nil)}
  end

  def handle_event("save_featured_url", %{"id" => id, "url" => url}, socket) do
    user_id = socket.assigns.current_user.id
    user_source = NewsSources.get_user_news_source(user_id, id)

    case NewsSources.update_user_news_source(user_source, %{custom_url: url}) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> assign(:editing_featured_id, nil)
         |> put_flash(:info, "Feed URL updated.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update URL.")}
    end
  end

  def handle_event("check_url", %{"url" => url}, socket) do
    case NewsSources.get_source_by_url(url) do
      nil ->
        # URL doesn't exist, show new source form
        {:noreply,
         socket
         |> assign(:modal_step, :new_source_form)
         |> assign(:url_input, url)
         |> assign(:found_source, nil)
         |> assign(:new_source, %{name: "", url: url, description: ""})}

      source ->
        # URL exists, show confirmation
        user_id = socket.assigns.current_user.id

        if NewsSources.user_subscribed?(user_id, source.id) do
          {:noreply,
           socket
           |> assign(:modal_step, nil)
           |> assign(:url_input, "")
           |> put_flash(:error, "You are already subscribed to this source.")}
        else
          {:noreply,
           socket
           |> assign(:modal_step, :confirm_existing)
           |> assign(:url_input, url)
           |> assign(:found_source, source)}
        end
    end
  end

  def handle_event("confirm_existing_source", _params, socket) do
    user_id = socket.assigns.current_user.id
    source = socket.assigns.found_source

    case NewsSources.add_user_source(user_id, source.id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> assign(:modal_step, nil)
         |> assign(:url_input, "")
         |> assign(:found_source, nil)
         |> put_flash(:info, "Successfully subscribed to #{source.name}.")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to subscribe to source.")}
    end
  end

  def handle_event("add_new_source", params, socket) do
    user_id = socket.assigns.current_user.id
    url = params["url"]

    content_type =
      if String.contains?(url, "youtube.com"), do: :video, else: :article

    attrs = %{
      name: params["name"],
      url: url,
      description: params["description"] || "",
      content_type: content_type
    }

    case NewsSources.create_and_add_user_source(user_id, attrs) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> assign(:modal_step, nil)
         |> assign(:url_input, "")
         |> assign(:new_source, %{name: "", url: "", description: ""})
         |> put_flash(:info, "Source added successfully.")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Failed to add source.")}
    end
  end

  def handle_event("fetch_source", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id

    %{news_source_id: id, user_id: user_id}
    |> FetchSingleSourceJob.new()
    |> Oban.insert()

    {:noreply, put_flash(socket, :info, "Fetch queued.")}
  end

  def handle_event("edit_source", %{"id" => id}, socket) do
    source = NewsSources.get_source(id)

    {:noreply,
     socket
     |> assign(:editing_source_id, id)
     |> assign(:edit_form, %{
       name: source.name,
       url: source.url,
       description: source.description || ""
     })}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_source_id, nil)
     |> assign(:edit_form, %{name: "", url: "", description: ""})}
  end

  def handle_event("save_source", %{"id" => id} = params, socket) do
    user_id = socket.assigns.current_user.id
    source = NewsSources.get_source(id)

    attrs = %{
      name: params["name"],
      url: params["url"],
      description: params["description"] || ""
    }

    case NewsSources.update_source(source, attrs) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> assign(:editing_source_id, nil)
         |> assign(:edit_form, %{name: "", url: "", description: ""})
         |> put_flash(:info, "Source updated successfully.")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Failed to update source.")}
    end
  end

  def handle_event("toggle_active", %{"id" => source_id}, socket) do
    user_id = socket.assigns.current_user.id

    user_feed_source = NewsSources.get_user_news_source(user_id, source_id)

    case NewsSources.update_user_news_source(user_feed_source, %{
           is_active: !user_feed_source.is_active
         }) do
      {:ok, _user_feed_source} ->
        {:noreply, assign_sources(socket, user_id)}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Failed to toggle source status.")}
    end
  end

  def handle_event("delete_source", %{"id" => source_id}, socket) do
    user_id = socket.assigns.current_user.id

    case NewsSources.remove_user_source(user_id, source_id) do
      {1, _} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> put_flash(:info, "Successfully unsubscribed from source.")}

      {0, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to unsubscribe from source.")}
    end
  end

  defp assign_sources(socket, user_id) do
    featured_names = MapSet.new(@featured_sources, & &1.name)
    all_sources = NewsSources.list_user_sources(user_id)

    is_featured_source? = fn {s, _} ->
      s.is_featured or MapSet.member?(featured_names, s.name)
    end

    {featured_user_sources, regular_sources} = Enum.split_with(all_sources, is_featured_source?)

    # name => {source, user_source} — used to render controls on Discover cards
    featured_subscriptions =
      featured_user_sources
      |> Enum.map(fn {s, us} -> {s.name, {s, us}} end)
      |> Map.new()

    socket
    |> assign(:sources, regular_sources)
    |> assign(:featured_subscriptions, featured_subscriptions)
  end
end
