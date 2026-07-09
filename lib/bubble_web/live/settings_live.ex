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
    <div class="min-h-screen bg-white dark:bg-[#0a0a0c]">
      <header class="fixed top-0 left-0 right-0 z-10 bg-white/90 dark:bg-[#0a0a0c]/90 backdrop-blur-sm border-b border-gray-200 dark:border-[#26262a]">
        <div class="max-w-[480px] mx-auto px-4 py-3 flex items-center justify-between">
          <div class="flex items-center gap-7">
            <span class="text-[13px] font-bold tracking-[0.14em] uppercase text-gray-900 dark:text-white">
              Bubble
            </span>
            <nav class="flex items-center gap-1">
              <.link
                navigate={~p"/"}
                class="px-3 py-2.5 text-[13px] font-semibold rounded-lg text-gray-500 dark:text-[#71717a] hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                Feed
              </.link>
              <.link
                navigate={~p"/settings"}
                class="px-3 py-2.5 text-[13px] font-semibold rounded-lg bg-orange-50 dark:bg-orange-400/10 text-gray-900 dark:text-white"
              >
                Settings
              </.link>
            </nav>
          </div>
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
              href={~p"/users/log_out"}
              method="delete"
              class="text-[13px] text-gray-500 dark:text-[#a1a1aa] hover:text-gray-900 dark:hover:text-white transition-colors"
            >
              Log out
            </.link>
          </div>
        </div>
      </header>

      <div class="max-w-[480px] mx-auto px-4 pt-[72px] pb-20">
        <!-- Discover section -->
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
                    <button
                      phx-click="toggle_active"
                      phx-value-id={db_source.id}
                      class={[
                        "shrink-0 relative inline-flex items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2",
                        "w-[46px] h-[27px]",
                        if(user_source.is_active,
                          do: "bg-orange-400",
                          else: "bg-gray-200 dark:bg-[#3f3f46]"
                        )
                      ]}
                    >
                      <span class={[
                        "inline-block w-[21px] h-[21px] transform rounded-full bg-white transition-transform",
                        if(user_source.is_active, do: "translate-x-[22px]", else: "translate-x-[3px]")
                      ]}>
                      </span>
                    </button>
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
                    <button
                      phx-click="edit_featured"
                      phx-value-id={db_source.id}
                      title="Edit feed URL"
                      class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-orange-400 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
                      phx-value-id={db_source.id}
                      title="Fetch now"
                      class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-orange-400 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
                        <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" />
                      </svg>
                    </button>
                    <button
                      phx-click="delete_source"
                      phx-value-id={db_source.id}
                      data-confirm={"Unsubscribe from #{source.name}?"}
                      title="Unsubscribe"
                      class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-red-500 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
                <% end %>
              </div>
            <% end %>
          </div>
        </section>

        <!-- RSS Sources section -->
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
                          {source.name}
                        </span>
                        <p class="text-[12px] text-gray-400 dark:text-[#52525b] mt-0.5 break-all">
                          {source.url}
                        </p>
                        <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed mt-1">
                          {source.description || "No description"}
                        </p>
                      </div>
                      <button
                        phx-click="toggle_active"
                        phx-value-id={source.id}
                        class={[
                          "shrink-0 relative inline-flex items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2",
                          "w-[46px] h-[27px]",
                          if(user_source.is_active,
                            do: "bg-orange-400",
                            else: "bg-gray-200 dark:bg-[#3f3f46]"
                          )
                        ]}
                      >
                        <span class={[
                          "inline-block w-[21px] h-[21px] transform rounded-full bg-white transition-transform",
                          if(user_source.is_active, do: "translate-x-[22px]", else: "translate-x-[3px]")
                        ]}>
                        </span>
                      </button>
                    </div>
                    <div class="flex items-center justify-between pt-3 border-t border-gray-100 dark:border-[#1f1f22]">
                      <p class="text-[12px] text-gray-400 dark:text-[#52525b]">
                        Subscribed {Calendar.strftime(user_source.inserted_at, "%b %d, %Y")}
                      </p>
                      <div class="flex gap-1">
                        <button
                          phx-click="edit_source"
                          phx-value-id={source.id}
                          title="Edit source"
                          class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-orange-400 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
                          class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-orange-400 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
                          class="w-11 h-11 flex items-center justify-center text-gray-500 dark:text-[#71717a] hover:text-red-500 transition-colors rounded-lg hover:bg-gray-50 dark:hover:bg-[#1f1f22]"
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
        </section>
      </div>

      <!-- Add Source Modal -->
      <%= if @modal_step != nil do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center px-4">
          <div
            class="absolute inset-0 bg-black/40"
            phx-click="cancel_add"
          />
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
                  <label for="modal_url" class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]">
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
                  <label for="modal_name" class="text-[11.5px] font-semibold tracking-[0.14em] uppercase text-gray-500 dark:text-[#71717a]">
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

    featured_subscriptions =
      featured_user_sources
      |> Enum.map(fn {s, us} -> {s.name, {s, us}} end)
      |> Map.new()

    socket
    |> assign(:sources, regular_sources)
    |> assign(:featured_subscriptions, featured_subscriptions)
  end
end
