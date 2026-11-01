defmodule BubbleWeb.SettingsLive do
  use BubbleWeb, :live_view

  import BubbleWeb.Components.AddSourceModal
  import BubbleWeb.Components.FeaturedSourceCard
  import BubbleWeb.Components.SourceRow

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
            <.section_heading>Discover</.section_heading>
            <span class="text-[12px] text-gray-400 dark:text-[#52525b]">
              Curated sources, one click to subscribe
            </span>
          </div>

          <div class="flex flex-col gap-3.5">
            <.featured_source_card
              :for={source <- @featured_sources}
              source={source}
              subscription={Map.get(@featured_subscriptions, source.name)}
              editing_source_id={@editing_source_id}
              edit_form={@edit_form}
            />
          </div>
        </section>

        <section>
          <div class="flex items-center justify-between mb-4">
            <.section_heading>Your Sources</.section_heading>
            <button
              phx-click="show_add_form"
              class="text-[12px] font-semibold text-orange-400 hover:text-orange-500 transition-colors"
            >
              + Add source
            </button>
          </div>

          <div class="flex flex-col gap-3.5">
            <.source_row
              :for={{source, user_source} <- @sources}
              source={source}
              user_source={user_source}
              editing_source_id={@editing_source_id}
              edit_form={@edit_form}
            />
          </div>
        </section>
      </div>

      <.add_source_modal
        modal_step={@modal_step}
        url_input={@url_input}
        found_source={@found_source}
        new_source={@new_source}
      />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    {:ok,
     socket
     |> assign_sources(user_id)
     |> assign(:featured_sources, @featured_sources)
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

    case subscribe_to_featured_source(user_id, attrs) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_sources(user_id)
         |> put_flash(:info, "Subscribed to #{attrs.name}.")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to subscribe.")}
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

    case NewsSources.subscribe_user_and_fetch(user_id, source.id) do
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

    case NewsSources.create_source_and_subscribe(user_id, attrs) do
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

  defp subscribe_to_featured_source(user_id, attrs) do
    case NewsSources.get_featured_source_by_name(attrs.name) do
      nil -> NewsSources.create_source_and_subscribe(user_id, Map.put(attrs, :is_featured, true))
      existing -> NewsSources.subscribe_user_and_fetch(user_id, existing.id)
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
