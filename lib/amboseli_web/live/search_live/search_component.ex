defmodule AmboseliWeb.SearchLive.SearchComponent do
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
      >
        <.input
          field={@form[:query]}
          type="search"
          id="search-input"
          placeholder="Search for notebooks"
          autofocus="true"
        />
        <.card
          :if={@notebooks}
          class="shadow-none rounded-none border-none"
          id="searchbox__results_list"
        >
          <.link
            :for={notebook <- @notebooks}
            navigate={~p"/notebooks/#{notebook}"}
            class="focus:outline-none focus:bg-slate-100 focus:text-sky-800 bg-none dark:focus:text-sky-200 dark:focus:bg-zinc-700 dark:text-white text-sm rounded-md"
          >
            <.card_content class="flex flex-row my-2 gap-2 space-x-2 rounded-md px-4 py-2 bg-zinc-100 hover:bg-zinc-600 hover:text-white items-center dark:bg-zinc-600 dark:hover:bg-zinc-700">
              <img
                src={notebook.pictures |> Enum.at(0) |> Map.get(:url)}
                class="w-10 h-10 rounded-md object-cover"
              />

              <%= notebook.title %>
            </.card_content>
          </.link>
        </.card>
      </.simple_search>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => ""}}, socket) do
    {:noreply,
     socket
     |> assign(:notebooks, [])}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    search_query = "%#{query}%"

    notebooks =
      Amboseli.Blog.Notebook
      |> order_by(asc: :title)
      |> where([p], ilike(p.title, ^search_query))
      |> limit(5)
      |> Amboseli.Repo.all()
      |> Ash.load!(AmboseliWeb.NotebookLive.Show.notebook_fields(socket))

    {:noreply,
     socket
     |> assign(:notebooks, notebooks)}
  end

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_read(Amboseli.Blog.Notebook, :search_notebooks,
        as: "search",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end
end
