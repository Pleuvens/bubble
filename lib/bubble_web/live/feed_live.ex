defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  on_mount {BubbleWeb.UserAuth, :mount_current_user}

  alias Bubble.News
  alias Utils.DateFormatter

  def render(assigns) do
    ~H"""
    <div id="feed" class="min-h-screen bg-white" data-active={@current_index} phx-hook="FeedNav">
      <header class="fixed top-0 left-0 right-0 z-10 bg-white/90 backdrop-blur-sm border-b border-gray-100">
        <div class="max-w-2xl mx-auto px-6 py-4 flex items-center justify-between">
          <span class="text-sm font-semibold tracking-[0.18em] uppercase text-gray-900">Bubble</span>
          <%= if @current_user do %>
            <div class="flex items-center gap-4">
              <.link
                navigate={~p"/settings"}
                class="text-xs text-gray-500 hover:text-orange-400 uppercase tracking-wider transition-colors"
              >
                Settings
              </.link>
              <.link
                href={~p"/users/log_out"}
                method="delete"
                class="text-xs text-gray-400 hover:text-orange-400 uppercase tracking-wider transition-colors"
              >
                Log out
              </.link>
            </div>
          <% else %>
            <div class="flex items-center gap-4">
              <.link
                navigate={~p"/users/log_in"}
                class="text-xs text-gray-500 hover:text-orange-400 uppercase tracking-wider transition-colors"
              >
                Log in
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="text-xs px-4 py-1.5 bg-orange-400 text-white hover:bg-orange-500 uppercase tracking-wider transition-colors rounded"
              >
                Register
              </.link>
            </div>
          <% end %>
        </div>
      </header>

      <main class="max-w-2xl mx-auto px-6 pt-20 pb-20">
        <%= if length(@news) > 0 do %>
          <div class="divide-y divide-gray-100">
            <%= for {item, index} <- Enum.with_index(@news) do %>
              <article
                id={"news-item-#{index}"}
                class={"py-7 transition-all duration-150 #{if index == @current_index, do: "bg-orange-50/60 -mx-4 px-4 rounded-xl", else: ""}"}
              >
                <div class="flex items-center gap-2 mb-3">
                  <span class="text-[11px] font-semibold text-orange-400 uppercase tracking-widest">
                    {item.news_source.name}
                  </span>
                  <span class="text-gray-200 text-xs">·</span>
                  <time class="text-[11px] text-gray-400">
                    {DateFormatter.format_news_date(item.published_at)}
                  </time>
                </div>

                <%= if item.video_id not in [nil, ""] do %>
                  <div class="w-full aspect-video rounded-lg overflow-hidden bg-gray-100 mb-4">
                    <iframe
                      src={"https://www.youtube.com/embed/#{item.video_id}"}
                      class="w-full h-full"
                      frameborder="0"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                      allowfullscreen
                    >
                    </iframe>
                  </div>
                <% end %>

                <h2 class="text-[17px] font-semibold text-gray-900 leading-snug mb-2">
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
                  <p class="text-sm text-gray-500 leading-relaxed mb-3">
                    {item.description
                    |> HtmlSanitizeEx.strip_tags()
                    |> String.trim()
                    |> truncate(280)
                    |> linkify()}
                  </p>
                <% end %>

                <a
                  href={item.url}
                  target="_blank"
                  rel="noopener"
                  class="inline-flex items-center gap-1 text-[11px] font-semibold text-orange-400 hover:text-orange-500 uppercase tracking-widest transition-colors duration-150"
                >
                  {if item.video_id not in [nil, ""], do: "Watch", else: "Read"}
                  <span>→</span>
                </a>
              </article>
            <% end %>
          </div>
        <% else %>
          <%= if @current_user do %>
            <div class="flex flex-col items-center justify-center py-32 text-center">
              <p class="text-gray-400 text-base mb-2">Nothing here yet</p>
              <p class="text-gray-300 text-sm">
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
              <h2 class="text-4xl font-semibold text-gray-900 tracking-tight mb-4">
                Your feed, your way.
              </h2>
              <p class="text-gray-400 text-base max-w-sm leading-relaxed mb-10">
                Bubble brings together all your RSS feeds in one clean, distraction-free reader.
              </p>
              <div class="flex items-center gap-3">
                <.link
                  navigate={~p"/users/register"}
                  class="px-6 py-2.5 bg-orange-400 text-white text-sm uppercase tracking-wider hover:bg-orange-500 transition-colors rounded"
                >
                  Get Started
                </.link>
                <.link
                  navigate={~p"/users/log_in"}
                  class="px-6 py-2.5 border border-gray-200 text-gray-500 text-sm uppercase tracking-wider hover:border-orange-400 hover:text-orange-400 transition-colors rounded"
                >
                  Log In
                </.link>
              </div>
            </div>
          <% end %>
        <% end %>
      </main>

      <%= if @current_user && length(@news) > 0 do %>
        <div class="fixed bottom-5 right-5 text-[10px] text-gray-300 bg-white border border-gray-100 px-3 py-1.5 rounded-full shadow-sm">
          ↑↓ navigate &nbsp;·&nbsp; enter open
        </div>
      <% end %>
    </div>
    """
  end

  defp truncate(text, max) when byte_size(text) <= max, do: text
  defp truncate(text, max), do: String.slice(text, 0, max) <> "…"

  @url_regex ~r/(https?:\/\/[^\s]+)/

  defp linkify(text) do
    escaped = Phoenix.HTML.html_escape(text) |> Phoenix.HTML.safe_to_string()

    result =
      Regex.replace(@url_regex, escaped, fn url ->
        ~s(<a href="#{url}" target="_blank" rel="noopener" class="text-orange-400 hover:text-orange-500 underline underline-offset-2 break-all">#{url}</a>)
      end)

    Phoenix.HTML.raw(result)
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
     |> assign(:current_index, 0)}
  end

  def handle_event("set_index", %{"index" => idx}, socket) do
    count = length(socket.assigns.news)
    clamped = idx |> max(0) |> min(count - 1)
    {:noreply, assign(socket, :current_index, clamped)}
  end
end
