defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  alias Bubble.Feeds

  def render(assigns) do
    ~H"""
    <div id="feed" class="bg-gray-50 min-h-screen" data-active={@current_index} phx-hook="FeedNav">
      <!-- Header -->
      <%!-- <div class="fixed top-0 left-0 right-0 z-10 bg-white/80 backdrop-blur-sm"> --%>
      <%!--   <div class="flex items-center justify-center px-6 py-4"> --%>
      <%!--     <h1 class="text-sm uppercase tracking-wider text-gray-600">Bubble</h1> --%>
      <%!--   </div> --%>
      <%!-- </div> --%>
      <%!-- Current news --%>
      <div class="pt-16">
        <%= if length(@news) > 0 do %>
          <%= for index <- 0..(length(@news) - 1) do %>
            <div id={"news-item-#{index}"}>
              <div
                phx-click="toggle_expanded"
                class="min-h-screen flex flex-col items-center justify-center p-8 cursor-pointer transition-all duration-300 hover:bg-gray-50"
              >
                <div class="max-w-4xl mx-auto text-center">
                  <%!-- decorative line --%>
                  <div class="flex justify-center mb-8">
                    <div class="w-px h-16 bg-gradient-to-b from-transparent via-orange-400 to-transparent opacity-60">
                    </div>
                  </div>
                  <%!-- Title with arrow --%>
                  <div class="relative mb-8">
                    <h1 class="text-4xl md:text-5xl lg:text-6xl text-orange-400 tracking-wide leading-tight uppercase font-light">
                      {Enum.at(@news, index).title}
                    </h1>
                    <a
                      href={Enum.at(@news, index).url}
                      target="_blank"
                      class="absolute top-1/2 -translate-y-1/2 left-[calc(100%+8rem)] p-3 text-orange-400 hover:text-orange-500 transition-all duration-200 hover:scale-110 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-opacity-50 rounded-full"
                      aria-label="Read full article from source"
                    >
                      <Lucide.arrow_right size="48" class="md:w-10 md:h-10 lg:w-12 lg:h-12" />
                    </a>
                  </div>
                  <%!-- Decorative line below --%>
                  <div class="flex justify-center mb-8">
                    <div class="w-px h-16 bg-gradient-to-b from-transparent via-orange-400 to-transparent opacity-60">
                    </div>
                  </div>
                  <%!-- sorce and date --%>
                  <div class="text-xs text-gray-500 uppercase tracking-widest mb-4">
                    <%!-- {source} — {new Date(publishedAt).toLocaleDateString('en-US', {  --%>
                    <%!--   month: 'short',  --%>
                    <%!--   day: 'numeric', --%>
                    <%!--   year: 'numeric' --%>
                    <%!-- })} --%>
                    {Enum.at(@news, index).published_at}
                  </div>
                  <%!-- Expanded content section --%>
                  <%= if @expanded do %>
                    <div class="mt-8 text-sm text-gray-600 max-w-2xl mx-auto leading-relaxed">
                      {Enum.at(@news, index).content}
                    </div>
                  <% end %>
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
    news = Feeds.list_news()

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
