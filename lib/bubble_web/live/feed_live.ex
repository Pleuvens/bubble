defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="feed">
      <h1>Feed</h1>
      <p>Welcome to the feed page!</p>
      <ul>
        <%= for news_item <- @news do %>
          <li>
            <strong><%= news_item.title %></strong>: {news_item.content}
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    news = [
      %{title: "Breaking News 1", content: "Content for breaking news 1"},
      %{title: "Breaking News 2", content: "Content for breaking news 2"},
      %{title: "Breaking News 3", content: "Content for breaking news 3"}
    ]

    {:ok, assign(socket, :news, news)}
  end
end
