defmodule BubbleWeb.FeedLive do
  use BubbleWeb, :live_view

  import SaladUI.Card

  alias Bubble.Feeds

  def render(assigns) do
    ~H"""
    <div class="feed">
      <ul>
        <%= if @news == [] do %>
          <li>No news available at the moment.</li>
        <% else %>
          <%= for news_item <- @news do %>
            <li>
              <.card class="mb-4">
                <.card_header>
                  <.card_title>{news_item.title}</.card_title>
                  <.card_description>{news_item.description}</.card_description>
                </.card_header>
                <.card_content>
                  {raw(HtmlSanitizeEx.strip_tags(news_item.content))}
                </.card_content>
                <.card_footer>
                  <a href={news_item.url} target="_blank" rel="noopener noreferrer">Go to</a>
                </.card_footer>
              </.card>
            </li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    news = Feeds.list_news()

    {:ok, assign(socket, :news, news)}
  end
end
