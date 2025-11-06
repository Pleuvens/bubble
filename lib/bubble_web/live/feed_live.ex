defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  on_mount {BubbleWeb.UserAuth, :mount_current_user}

  alias Bubble.Feeds
  alias Utils.DateFormatter

  def render(assigns) do
    ~H"""
    <div id="feed" class="bg-gray-50 min-h-screen" data-active={@current_index} phx-hook="FeedNav">
      <!-- Header -->
      <div class="fixed top-0 left-0 right-0 z-10 bg-white/80 backdrop-blur-sm">
        <div class="flex items-center justify-between px-6 py-4">
          <h1 class="text-sm uppercase tracking-wider text-gray-600">Bubble</h1>
          <div class="flex items-center gap-4">
            <%= if @current_user do %>
              <span class="text-xs text-gray-600">{@current_user.email}</span>
              <.link
                href={~p"/users/settings"}
                class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors"
              >
                Account
              </.link>
              <.link
                href={~p"/users/log_out"}
                method="delete"
                class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors"
              >
                Log out
              </.link>
            <% else %>
              <.link
                navigate={~p"/users/log_in"}
                class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors"
              >
                Log in
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="text-xs uppercase tracking-wider text-gray-600 hover:text-orange-400 transition-colors"
              >
                Register
              </.link>
            <% end %>
            <.link
              navigate={~p"/settings"}
              class="text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-md hover:bg-gray-100"
              aria-label="Settings"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-5 h-5"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            </.link>
          </div>
        </div>
      </div>
      <%!-- Current news --%>
      <div class="pt-16">
        <%= if length(@news) > 0 do %>
          <%= for index <- 0..(length(@news) - 1) do %>
            <div id={"news-item-#{index}"}>
              <div
                phx-click="toggle_expanded"
                class={"min-h-screen flex flex-col p-8 cursor-pointer hover:bg-gray-50 #{if @expanded, do: "justify-start pt-16", else: "items-center justify-center"}"}
              >
                <div class="max-w-4xl mx-auto text-center w-full">
                  <%!-- decorative line --%>
                  <%= if index > 0 do %>
                    <div
                      class="flex justify-center mb-8 overflow-hidden"
                      style={"#{if @expanded, do: "max-height: 0; margin-bottom: 0; opacity: 0;", else: "max-height: 100px; opacity: 1;"}"}
                    >
                      <div class="w-px h-16 bg-gradient-to-b from-transparent via-orange-400 to-transparent opacity-60">
                      </div>
                    </div>
                  <% end %>
                  <%!-- Title with arrow --%>
                  <div class="relative mb-8">
                    <h1
                      class="text-4xl md:text-5xl lg:text-6xl text-orange-400 tracking-wide leading-tight uppercase font-light"
                      style={"transform-origin: center; #{if @expanded, do: "transform: scale(0.5);", else: "transform: scale(1);"}"}
                    >
                      {Enum.at(@news, index).title}
                    </h1>
                    <a
                      href={Enum.at(@news, index).url}
                      target="_blank"
                      phx-click="noop"
                      class="absolute top-1/2 -translate-y-1/2 left-[calc(100%+8rem)] p-3 text-orange-400 hover:text-orange-500 transition-all duration-200 hover:scale-110 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-opacity-50 rounded-full"
                      aria-label="Read full article from source"
                      onclick="event.stopPropagation();"
                    >
                      <Lucide.arrow_right size="48" class="md:w-10 md:h-10 lg:w-12 lg:h-12" />
                    </a>
                  </div>
                  <%!-- Decorative line below --%>
                  <%= if index < length(@news) - 1 do %>
                    <div
                      class="flex justify-center mb-8 overflow-hidden"
                      style={"#{if @expanded, do: "max-height: 0; margin-bottom: 0; opacity: 0;", else: "max-height: 100px; opacity: 1;"}"}
                    >
                      <div class="w-px h-16 bg-gradient-to-b from-transparent via-orange-400 to-transparent opacity-60">
                      </div>
                    </div>
                  <% end %>
                  <%!-- sorce and date --%>
                  <div class={"text-xs text-gray-500 uppercase tracking-widest #{if @expanded, do: "mb-8", else: "mb-4"}"}>
                    <%!-- {source} — {new Date(publishedAt).toLocaleDateString('en-US', {  --%>
                    <%!--   month: 'short',  --%>
                    <%!--   day: 'numeric', --%>
                    <%!--   year: 'numeric' --%>
                    <%!-- })} --%>
                    {DateFormatter.format_news_date(Enum.at(@news, index).published_at)}
                  </div>
                  <%!-- Expanded content section --%>
                  <div
                    class="flex items-center justify-center overflow-hidden"
                    style={"#{if @expanded, do: "max-height: 2000px; margin-top: 8rem;", else: "max-height: 0;"}"}
                  >
                    <div
                      class="text-base md:text-lg text-gray-700 max-w-3xl mx-auto leading-relaxed text-left px-4 py-4"
                      style={"#{if @expanded, do: "opacity: 1;", else: "opacity: 0;"}"}
                    >
                      {Enum.at(@news, index).content}
                    </div>
                  </div>
                  <%!-- Hint text at the bottom --%>
                  <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 text-xs text-gray-400 uppercase tracking-wider">
                    <%= if @expanded do %>
                      Click to collapse • Arrow to read full article
                    <% else %>
                      Click to expand • Arrow to read full article • Scroll to navigate
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
        <% else %>
          <div>No news</div>
        <% end %>
      </div>
      <div class="fixed bottom-4 left-4 text-xs text-gray-400 bg-white/80 backdrop-blur-sm px-3 py-2 rounded-lg">
        <div>↑↓ Navigate • Enter/Space Expand • Arrow→ Read article • Scroll to browse</div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    news =
      case socket.assigns.current_user do
        nil -> []
        user -> Feeds.list_user_news(user.id)
      end

    {:ok,
     socket
     |> assign(:news, news)
     |> assign(:current_index, 0)
     |> assign(:expanded, false)}
  end

  def handle_event("toggle_expanded", _params, socket) do
    {:noreply, assign(socket, :expanded, !socket.assigns.expanded)}
  end

  def handle_event("set_index", %{"index" => idx}, socket) do
    {:noreply, assign(socket, :current_index, idx)}
  end
end
