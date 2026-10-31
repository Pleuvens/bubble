defmodule BubbleWeb.SettingsLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.ActiveToggle
  import BubbleWeb.Components.IconButton

  alias Bubble.News.FetchSingleSourceJob
  alias Bubble.News.SourceOverride
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
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <.app_header current_page="settings" current_user={@current_user} />

      <div class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <section class="mb-10">
          <div class="flex items-center justify-between mb-4">
            <span class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]">
              Discover
            </span>
            <span class="text-[12px] text-gray-400 dark:text-[#52525b]">
              Curated sources, one click to subscribe
            </span>
          </div>

          <div class="flex flex-col gap-3.5">
            <%= for source <- @featured_sources do %>
              <% sub = Map.get(@featured_subscriptions, source.name) %>
              <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
                <div class="flex items-start justify-between gap-4">
                  <div class="flex-1">
                    <div class="flex items-center gap-2 mb-1">
                      <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
                        {source.name}
                      </span>
                      <%= if source.content_type == :video do %>
                        <span class="text-[11px] font-semibold uppercase tracking-wide bg-orange-50 dark:bg-orange-400/[0.14] text-orange-500 dark:text-orange-300 px-1.5 py-0.5 rounded-full">
                          Video
                        </span>
                      <% end %>
                    </div>
                    <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed">
                      {source.description}
                    </p>
                  </div>
                  <%= if sub do %>
                    <% {db_source, user_source} = sub %>
                    <.active_toggle source_id={db_source.id} active={user_source.is_active} />
                  <% else %>
                    <button
                      phx-click="subscribe_featured"
                      phx-value-url={source.url}
                      class="shrink-0 border border-orange-400 text-orange-400 hover:bg-orange-400 hover:text-white uppercase tracking-wider px-3 py-1.5 rounded-lg transition-all text-[12px] font-semibold"
                    >
                      Subscribe
                    </button>
                  <% end %>
                </div>
                <%!-- Edit URL form --%>
                <%= if sub && elem(sub, 0).id == @editing_featured_id do %>
                  <% {db_source, db_user_source} = sub %>
                  <form
                    phx-submit="save_featured_url"
                    phx-value-id={db_source.id}
                    class="mt-4 flex gap-2"
                  >
                    <input
                      type="url"
                      name="url"
                      value={db_user_source.custom_url || db_source.url}
                      placeholder="https://www.youtube.com/feeds/videos.xml?..."
                      required
                      class="flex-1 px-3 py-2 text-sm border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white"
                    />
                    <button
                      type="submit"
                      class="px-3 py-2 bg-orange-400 hover:bg-orange-500 text-white rounded-lg text-xs uppercase tracking-wider transition-colors"
                    >
                      Save
                    </button>
                    <button
                      type="button"
                      phx-click="cancel_edit_featured"
                      class="px-3 py-2 border border-gray-200 dark:border-[#26262a] text-gray-600 dark:text-[#a1a1aa] rounded-lg text-xs uppercase tracking-wider hover:bg-gray-50 dark:hover:bg-[#1f1f22] transition-colors"
                    >
                      Cancel
                    </button>
                  </form>
                <% end %>
                <%!-- Controls row (only when subscribed and not editing) --%>
                <%= if sub && elem(sub, 0).id != @editing_featured_id do %>
                  <% {db_source, _} = sub %>
                  <div class="flex items-center justify-end gap-1 pt-3 mt-3 border-t border-gray-100 dark:border-[#1f1f22]">
                    <.icon_button
                      click="edit_featured"
                      source_id={db_source.id}
                      title="Edit feed URL"
                      icon={:pencil}
                    />
                    <.icon_button
                      click="fetch_source"
                      source_id={db_source.id}
                      title="Fetch now"
                      icon={:refresh}
                    />
                    <.icon_button
                      click="delete_source"
                      source_id={db_source.id}
                      title="Unsubscribe"
                      icon={:trash}
                      hover_tone={:red}
                      confirm={"Unsubscribe from #{source.name}?"}
                    />
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </section>

        <section>
          <div class="flex items-center justify-between mb-4">
            <span class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]">
              Your Sources
            </span>
            <button
              phx-click="show_add_form"
              class="text-[12px] font-semibold text-orange-400 hover:text-orange-500 transition-colors"
            >
              + Add source
            </button>
          </div>

          <div class="flex flex-col gap-3.5">
            <%= for {source, user_source} <- @sources do %>
              <div class="bg-white dark:bg-[#141416] rounded-xl border border-gray-200 dark:border-[#26262a] p-4">
                <%= if @editing_source_id == source.id do %>
                  <form phx-submit="save_source" phx-value-id={source.id} class="space-y-3">
                    <div class="space-y-1.5">
                      <label
                        for={"edit_name_#{source.id}"}
                        class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                      >
                        Name
                      </label>
                      <input
                        type="text"
                        id={"edit_name_#{source.id}"}
                        name="name"
                        value={@edit_form.name}
                        required
                        class="w-full px-3 py-2 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
                      />
                    </div>
                    <div class="space-y-1.5">
                      <label
                        for={"edit_url_#{source.id}"}
                        class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                      >
                        RSS URL
                      </label>
                      <input
                        type="url"
                        id={"edit_url_#{source.id}"}
                        name="url"
                        value={@edit_form.url}
                        required
                        class="w-full px-3 py-2 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
                      />
                    </div>
                    <div class="space-y-1.5">
                      <label
                        for={"edit_description_#{source.id}"}
                        class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                      >
                        Description
                      </label>
                      <textarea
                        id={"edit_description_#{source.id}"}
                        name="description"
                        rows="2"
                        class="w-full px-3 py-2 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none resize-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
                      ><%= @edit_form.description %></textarea>
                    </div>
                    <div class="flex gap-2">
                      <button
                        type="submit"
                        class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2 rounded-lg text-[13px] font-semibold uppercase tracking-wide transition-colors"
                      >
                        Save
                      </button>
                      <button
                        type="button"
                        phx-click="cancel_edit"
                        class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2 rounded-lg text-[13px] font-semibold uppercase tracking-wide transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  </form>
                <% else %>
                  <div>
                    <div class="flex items-start justify-between gap-4 mb-3">
                      <div class="flex-1 min-w-0">
                        <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
                          {SourceOverride.name(source, user_source)}
                        </span>
                        <p class="text-[12px] text-gray-400 dark:text-[#52525b] mt-0.5 break-all">
                          {SourceOverride.url(source, user_source)}
                        </p>
                        <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed mt-1">
                          {SourceOverride.description(source, user_source) || "No description"}
                        </p>
                      </div>
                      <.active_toggle source_id={source.id} active={user_source.is_active} />
                    </div>
                    <div class="flex items-center justify-between pt-3 border-t border-gray-100 dark:border-[#1f1f22]">
                      <p class="text-[12px] text-gray-400 dark:text-[#52525b]">
                        Subscribed {Calendar.strftime(user_source.inserted_at, "%b %d, %Y")}
                      </p>
                      <div class="flex gap-1">
                        <.icon_button
                          click="edit_source"
                          source_id={source.id}
                          title="Edit source"
                          icon={:pencil}
                        />
                        <.icon_button
                          click="fetch_source"
                          source_id={source.id}
                          title="Fetch now"
                          icon={:refresh}
                        />
                        <.icon_button
                          click="delete_source"
                          source_id={source.id}
                          title="Unsubscribe"
                          icon={:trash}
                          hover_tone={:red}
                          confirm="Are you sure you want to unsubscribe from this RSS source?"
                        />
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </section>
      </div>

      <%= if @modal_step != nil do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center px-4">
          <div class="absolute inset-0 bg-black/40" phx-click="cancel_add" />
          <div class="relative w-full max-w-[380px] bg-white dark:bg-[#141416] rounded-2xl p-6 shadow-2xl">
            <div class="flex items-center justify-between mb-5">
              <span class="text-[14.5px] font-semibold text-gray-900 dark:text-white">
                <%= case @modal_step do %>
                  <% :url_input -> %>
                    Add RSS source
                  <% :confirm_existing -> %>
                    Subscribe to source
                  <% :new_source_form -> %>
                    Add new source
                <% end %>
              </span>
              <button
                phx-click="cancel_add"
                class="w-11 h-11 flex items-center justify-center text-gray-400 dark:text-[#71717a] hover:text-gray-900 dark:hover:text-white transition-colors rounded-lg hover:bg-gray-100 dark:hover:bg-[#1f1f22]"
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
              </button>
            </div>

            <%= if @modal_step == :url_input do %>
              <form phx-submit="check_url" class="space-y-4">
                <div class="space-y-1.5">
                  <label
                    for="modal_url"
                    class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                  >
                    RSS URL
                  </label>
                  <input
                    type="url"
                    id="modal_url"
                    name="url"
                    value={@url_input}
                    placeholder="https://example.com/rss"
                    required
                    class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
                  />
                </div>
                <div class="flex gap-2 mt-2">
                  <button
                    type="submit"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Next
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            <% end %>

            <%= if @modal_step == :confirm_existing do %>
              <div class="space-y-4">
                <div class="bg-gray-50 dark:bg-[#1f1f22] p-4 rounded-lg">
                  <h4 class="text-[14.5px] font-semibold text-gray-900 dark:text-white mb-1">
                    {@found_source.name}
                  </h4>
                  <p class="text-[12px] text-gray-400 dark:text-[#52525b] mb-1 break-all">
                    {@found_source.url}
                  </p>
                  <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa]">
                    {@found_source.description || "No description"}
                  </p>
                </div>
                <p class="text-[13px] text-gray-500 dark:text-[#a1a1aa] text-center">
                  This source already exists. Subscribe to it?
                </p>
                <div class="flex gap-2">
                  <button
                    type="button"
                    phx-click="confirm_existing_source"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Subscribe
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            <% end %>

            <%= if @modal_step == :new_source_form do %>
              <form phx-submit="add_new_source" class="space-y-4">
                <div class="space-y-1.5">
                  <label class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]">
                    RSS URL
                  </label>
                  <input type="hidden" name="url" value={@new_source.url} />
                  <p class="text-[13px] text-gray-500 dark:text-[#a1a1aa] bg-gray-50 dark:bg-[#1f1f22] px-3 py-2 rounded-lg break-all">
                    {@new_source.url}
                  </p>
                </div>
                <div class="space-y-1.5">
                  <label
                    for="modal_name"
                    class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]"
                  >
                    Name
                  </label>
                  <input
                    type="text"
                    id="modal_name"
                    name="name"
                    value={@new_source.name}
                    placeholder="e.g. Tech News"
                    required
                    class="w-full px-3 py-2.5 border border-gray-200 dark:border-[#26262a] rounded-lg focus:border-orange-400 focus:ring focus:ring-orange-400 focus:ring-opacity-20 outline-none bg-white dark:bg-[#0a0a0c] text-gray-900 dark:text-white text-sm transition"
                  />
                </div>
                <div class="flex gap-2 mt-2">
                  <button
                    type="submit"
                    class="flex-1 bg-orange-400 hover:bg-orange-500 text-white px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Add source
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_add"
                    class="flex-1 border border-gray-200 dark:border-[#26262a] text-gray-700 dark:text-[#a1a1aa] hover:bg-gray-50 dark:hover:bg-[#1f1f22] px-4 py-2.5 rounded-lg text-[13px] font-bold uppercase tracking-wide transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            <% end %>
          </div>
        </div>
      <% end %>
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
    case NewsSources.get_user_news_source(socket.assigns.current_user.id, id) do
      nil ->
        {:noreply,
         socket
         |> assign(:editing_featured_id, nil)
         |> refresh_with_error("You are not subscribed to that source.")}

      user_source ->
        save_user_source_url(socket, user_source, url)
    end
  end

  def handle_event("check_url", %{"url" => url}, socket) do
    case NewsSources.get_source_by_url(url) do
      nil ->
        {:noreply,
         socket
         |> assign(:modal_step, :new_source_form)
         |> assign(:url_input, url)
         |> assign(:found_source, nil)
         |> assign(:new_source, %{name: "", url: url, description: ""})}

      source ->
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
    user_id = socket.assigns.current_user.id

    case NewsSources.get_subscribed_source(user_id, id) do
      nil ->
        {:noreply, put_flash(socket, :error, "You are not subscribed to that source.")}

      {source, user_source} ->
        {:noreply,
         socket
         |> assign(:editing_source_id, id)
         |> assign(:edit_form, %{
           name: SourceOverride.name(source, user_source),
           url: SourceOverride.url(source, user_source),
           description: SourceOverride.description(source, user_source) || ""
         })}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_source_id, nil)
     |> assign(:edit_form, %{name: "", url: "", description: ""})}
  end

  def handle_event("save_source", %{"id" => id} = params, socket) do
    user_id = socket.assigns.current_user.id

    case NewsSources.get_subscribed_source(user_id, id) do
      nil ->
        {:noreply, put_flash(socket, :error, "You are not subscribed to that source.")}

      {source, user_source} ->
        save_source_overrides(socket, source, user_source, params)
    end
  end

  def handle_event("toggle_active", %{"id" => source_id}, socket) do
    user_id = socket.assigns.current_user.id

    case NewsSources.get_user_news_source(user_id, source_id) do
      nil ->
        {:noreply, refresh_with_error(socket, "You are not subscribed to that source.")}

      user_feed_source ->
        toggle_user_source_active(socket, user_feed_source)
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

  defp save_user_source_url(socket, user_source, url) do
    case NewsSources.update_user_news_source(user_source, %{custom_url: url}) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_sources(socket.assigns.current_user.id)
         |> assign(:editing_featured_id, nil)
         |> put_flash(:info, "Feed URL updated.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update URL.")}
    end
  end

  defp toggle_user_source_active(socket, user_feed_source) do
    case NewsSources.update_user_news_source(user_feed_source, %{
           is_active: !user_feed_source.is_active
         }) do
      {:ok, _user_feed_source} ->
        {:noreply, assign_sources(socket, socket.assigns.current_user.id)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to toggle source status.")}
    end
  end

  defp refresh_with_error(socket, message) do
    socket
    |> assign_sources(socket.assigns.current_user.id)
    |> put_flash(:error, message)
  end

  defp save_source_overrides(socket, source, user_source, params) do
    user_id = socket.assigns.current_user.id

    attrs = %{
      custom_name: override_or_nil(params["name"], source.name),
      custom_url: override_or_nil(params["url"], source.url),
      custom_description: override_or_nil(params["description"], source.description)
    }

    case NewsSources.update_user_news_source(user_source, attrs) do
      {:ok, _user_source} ->
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

  defp override_or_nil(submitted, _shared) when submitted in [nil, ""], do: nil
  defp override_or_nil(submitted, shared) when submitted == shared, do: nil
  defp override_or_nil(submitted, _shared), do: submitted

  defp assign_sources(socket, user_id) do
    featured_names = MapSet.new(@featured_sources, & &1.name)
    all_sources = NewsSources.list_user_sources(user_id)

    is_featured_source? = fn {s, _} ->
      s.is_featured or MapSet.member?(featured_names, s.name)
    end

    {featured_user_sources, regular_sources} = Enum.split_with(all_sources, is_featured_source?)

    featured_subscriptions =
      featured_user_sources
      |> Enum.map(fn {s, us} -> {s.name, {s, us}} end)
      |> Map.new()

    socket
    |> assign(:sources, regular_sources)
    |> assign(:featured_subscriptions, featured_subscriptions)
  end
end
