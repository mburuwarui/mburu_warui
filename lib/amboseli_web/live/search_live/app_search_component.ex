defmodule AmboseliWeb.AppLive.SearchComponent do
  require Ash.Query
  use AmboseliWeb, :live_component

  import Ecto.Query, warn: false

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_search
        for={@form}
        id="searchbox_container"
        phx-change="search"
        phx-target={@myself}
        phx-debounce="300"
        phx-hook="SearchBar"
        phx-submit="search-submit"
      >
        <.input
          field={@form[:query]}
          type="search"
          id="search-input"
          placeholder="Search for apps"
          autofocus="true"
          class="w-full"
          tabindex="0"
        />
        <div id="search-results">
          <%= if @apps && !Enum.empty?(@apps) do %>
            <div class="shadow-none rounded-none border-none">
              <%= for app <- @apps do %>
                <.link
                  navigate={~p"/apps/#{app}"}
                  class="block focus:outline-none focus:bg-slate-100 focus:text-sky-800 bg-none dark:focus:text-sky-200 dark:focus:bg-zinc-700 dark:text-white text-sm rounded-md"
                  tabindex="0"
                >
                  <.card_content class="flex flex-row my-2 gap-2 space-x-2 rounded-md px-4 py-2 bg-zinc-100 hover:bg-zinc-600 hover:text-white items-center dark:bg-zinc-600 dark:hover:bg-zinc-700">
                    <img src={app.picture} class="w-10 h-10 rounded-md object-cover" />
                    <%= app.title %>
                  </.card_content>
                </.link>
              <% end %>
            </div>
          <% end %>

          <%= if @current_query != "" && @searched && Enum.empty?(@apps) do %>
            <div class="flex flex-row my-2 gap-2 space-x-2 rounded-md px-4 py-2 bg-zinc-100 dark:bg-zinc-600 dark:text-white text-sm items-center">
              No results found for "<%= @current_query %>"
            </div>
          <% end %>
        </div>
      </.simple_search>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:apps, [])
     |> assign(:searched, false)
     |> assign(:current_query, "")
     |> assign_form()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => ""}}, socket) do
    {:noreply,
     socket
     |> assign(:apps, [])
     |> assign(:searched, false)
     |> assign(:current_query, "")}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    if String.trim(query) == "" do
      {:noreply,
       socket
       |> assign(:apps, [])
       |> assign(:searched, false)
       |> assign(:current_query, "")}
    else
      search_query = "%#{query}%"

      apps =
        Amboseli.Catalog.App
        |> order_by(asc: :title)
        |> where([p], ilike(p.title, ^search_query))
        |> limit(5)
        |> Amboseli.Repo.all()
        |> Ash.load!([
          :categories_join_assoc,
          :categories,
          :user_email,
          :user
        ])

      {:noreply,
       socket
       |> assign(:apps, apps)
       |> assign(:searched, true)
       |> assign(:current_query, query)}
    end
  end

  @impl true
  def handle_event("search-submit", %{"search" => %{"query" => query}}, socket) do
    if String.trim(query) == "" do
      {:noreply,
       socket
       |> assign(:apps, [])
       |> assign(:searched, false)
       |> assign(:current_query, "")}
    else
      search_query = "%#{query}%"

      apps =
        Amboseli.Catalog.App
        |> order_by(asc: :title)
        |> where([p], ilike(p.title, ^search_query))
        |> limit(5)
        |> Amboseli.Repo.all()
        |> Ash.load!([
          :categories_join_assoc,
          :categories,
          :user_email,
          :user
        ])

      {:noreply,
       socket
       |> assign(:apps, apps)
       |> assign(:searched, true)
       |> assign(:current_query, query)}
    end
  end

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_read(Amboseli.Catalog.App, :search_apps,
        as: "search",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end
end
