defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  on_mount {BubbleWeb.UserAuth, :mount_current_user}

  alias Bubble.News
  alias Utils.DateFormatter

  @per_page 20

  def render(assigns) do
    ~H"""
    <div
      id="feed"
      class="min-h-screen bg-white dark:bg-[#0a0a0c]"
      data-active={@current_index}
      phx-hook="FeedNav"
    >
      <.app_header current_page="feed" current_user={@current_user} />

      <main class="max-w-[480px] mx-auto px-4 pt-[60px] pb-20">
        <%= if length(@news) > 0 do %>
          <div>
            <%= for {item, index} <- Enum.with_index(Enum.take(@news, @page * @per_page)) do %>
              <article
                id={"news-item-#{index}"}
                class={[
                  "py-[22px] border-b border-gray-100 dark:border-[#1f1f22]",
                  index == @current_index &&
                    "bg-orange-50/60 dark:bg-orange-400/5 -mx-4 px-4"
                ]}
              >
                <div class="flex gap-3.5">
                  <div class={[
                    "w-10 h-10 rounded-[9px] flex-shrink-0 flex items-center justify-center font-mono text-[11.5px] font-bold tracking-[0.02em]",
                    if(item.news_source.content_type == :video,
                      do:
                        "bg-orange-50 dark:bg-orange-400/[0.14] text-orange-600 dark:text-orange-300",
                      else: "bg-gray-100 dark:bg-[#1f1f22] text-gray-500 dark:text-[#71717a]"
                    )
                  ]}>
                    {source_initials(item.news_source.name)}
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 mb-1.5">
                      <span class="text-[12px] font-semibold text-orange-400 uppercase tracking-wide">
                        {item.news_source.name}
                      </span>
                      <span class="text-gray-200 dark:text-[#3f3f46] text-xs">·</span>
                      <time class="text-[12px] text-gray-400 dark:text-[#71717a]">
                        {DateFormatter.format_news_date(item.published_at)}
                      </time>
                      <%= if item.news_source.content_type == :video do %>
                        <span class="text-[11px] font-semibold uppercase tracking-wide bg-orange-50 dark:bg-orange-400/[0.14] text-orange-500 dark:text-orange-300 px-1.5 py-0.5 rounded-full">
                          Video
                        </span>
                      <% end %>
                    </div>

                    <%= if item.video_id not in [nil, ""] do %>
                      <div class="w-full aspect-video rounded-[10px] bg-gray-100 dark:bg-[#1f1f22] mb-3 flex items-center justify-center">
                        <svg
                          class="w-10 h-10 text-gray-300 dark:text-[#3f3f46]"
                          viewBox="0 0 24 24"
                          fill="currentColor"
                        >
                          <path d="M8 5v14l11-7z" />
                        </svg>
                      </div>
                    <% end %>

                    <h2 class="text-[17px] font-semibold text-gray-900 dark:text-white leading-snug mb-2">
                      <a
                        href={item.url}
                        target="_blank"
                        rel="noopener"
                        class="hover:text-orange-400 transition-colors duration-150"
                      >
                        {item.title}
                      </a>
                    </h2>

                    <%= if item.description not in [nil, ""] do %>
                      <p class="text-[13.5px] text-gray-500 dark:text-[#a1a1aa] leading-relaxed mb-2.5">
                        <.text_with_links text={
                          item.description
                          |> HtmlSanitizeEx.strip_tags()
                          |> String.trim()
                          |> truncate(280)
                        } />
                      </p>
                    <% end %>

                    <a
                      href={item.url}
                      target="_blank"
                      rel="noopener"
                      class="inline-flex items-center gap-1 text-[12px] font-semibold text-orange-400 hover:text-orange-500 uppercase tracking-widest transition-colors duration-150"
                    >
                      {if item.video_id not in [nil, ""], do: "Watch", else: "Read"}
                      <span>→</span>
                    </a>
                  </div>
                </div>
              </article>
            <% end %>
          </div>

          <%= if length(@news) > @page * @per_page do %>
            <div class="text-center mt-8">
              <button
                phx-click="load_more"
                class="rounded-full border border-gray-200 dark:border-[#26262a] px-6 py-2 text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-[#a1a1aa] hover:border-orange-400 hover:text-orange-400 transition-colors"
              >
                Load more
              </button>
            </div>
          <% end %>
        <% else %>
          <%= if @current_user do %>
            <div class="flex flex-col items-center justify-center py-32 text-center">
              <p class="text-gray-400 dark:text-[#71717a] text-base mb-2">Nothing here yet</p>
              <p class="text-gray-300 dark:text-[#52525b] text-sm">
                Add sources in
                <.link
                  navigate={~p"/settings"}
                  class="text-orange-400 hover:text-orange-500 underline"
                >
                  settings
                </.link>
                to start reading
              </p>
            </div>
          <% else %>
            <div class="flex flex-col items-center justify-center min-h-[80vh] text-center">
              <h2 class="text-4xl font-semibold text-gray-900 dark:text-white tracking-tight mb-4">
                Your feed, your way.
              </h2>
              <p class="text-gray-400 dark:text-[#71717a] text-base max-w-sm leading-relaxed mb-10">
                Bubble brings together all your RSS feeds in one clean, distraction-free reader.
              </p>
              <div class="flex items-center gap-3">
                <.link
                  navigate={~p"/users/register"}
                  class="px-6 py-2.5 bg-orange-400 text-white text-sm uppercase tracking-wider hover:bg-orange-500 transition-colors rounded-lg"
                >
                  Get Started
                </.link>
                <.link
                  navigate={~p"/users/log_in"}
                  class="px-6 py-2.5 border border-gray-200 dark:border-[#26262a] text-gray-500 dark:text-[#a1a1aa] text-sm uppercase tracking-wider hover:border-orange-400 hover:text-orange-400 transition-colors rounded-lg"
                >
                  Log In
                </.link>
              </div>
            </div>
          <% end %>
        <% end %>
      </main>

      <%= if @current_user && length(@news) > 0 do %>
        <div class="fixed bottom-5 right-5 text-[10px] text-gray-300 dark:text-[#52525b] bg-white dark:bg-[#141416] border border-gray-100 dark:border-[#26262a] px-3 py-1.5 rounded-full shadow-sm">
          ↑↓ navigate &nbsp;·&nbsp; enter open
        </div>
      <% end %>
    </div>
    """
  end

  defp source_initials(name) do
    name
    |> String.split(~r/\s+/)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join("")
    |> String.upcase()
  end

  defp truncate(text, max_characters) do
    case String.split_at(text, max_characters) do
      {kept, ""} -> kept
      {kept, _dropped} -> kept <> "…"
    end
  end

  @url_regex ~r/https?:\/\/[^\s]+/

  attr :text, :string, required: true

  defp text_with_links(assigns) do
    assigns = assign(assigns, :parts, split_around_urls(assigns.text))

    ~H"""
    <%= for part <- @parts do %>
      <%= case part do %>
        <% {:url, url} -> %>
          <a
            href={url}
            target="_blank"
            rel="noopener"
            class="text-orange-400 hover:text-orange-500 underline underline-offset-2 break-all"
          >{url}</a>
        <% {:plain, plain} -> %>
          {plain}
      <% end %>
    <% end %>
    """
  end

  defp split_around_urls(text) do
    @url_regex
    |> Regex.split(text, include_captures: true, trim: true)
    |> Enum.map(&tag_part/1)
  end

  defp tag_part(part) do
    if Regex.match?(@url_regex, part), do: {:url, part}, else: {:plain, part}
  end

  def mount(_params, _session, socket) do
    news =
      case socket.assigns.current_user do
        nil -> []
        user -> News.list_user_news(user.id)
      end

    {:ok,
     socket
     |> assign(:news, news)
     |> assign(:current_index, 0)
     |> assign(:page, 1)
     |> assign(:per_page, @per_page)}
  end

  def handle_event("set_index", %{"index" => idx}, socket) do
    count = length(socket.assigns.news)
    clamped = idx |> max(0) |> min(count - 1)
    {:noreply, assign(socket, :current_index, clamped)}
  end

  def handle_event("load_more", _params, socket) do
    {:noreply, assign(socket, :page, socket.assigns.page + 1)}
  end
end
