defmodule AmboseliWeb.AppLive.Index do
  use AmboseliWeb, :blog_view

  @impl true
  def render(assigns) do
    ~H"""
    <section class="container px-6 py-8 mx-auto lg:py-16">
      <.header>
        <div class="w-full text-center mb-4 sm:mb-10">
          <h1 class="text-4xl font-extrabold dark:text-white">Explore My Expertise</h1>
        </div>

        <div class="py-4 flex sm:flex-row flex-col justify-between gap-4 items-center">
          <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <div class="flex flex-wrap gap-2 w-full sm:w-auto">
              <.link
                :for={category <- @categories}
                patch={~p"/apps/category/#{category.id}"}
                class="w-full sm:w-auto"
              >
                <button
                  class={[
                    "w-full sm:w-auto px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                    @current_category == category.id && "bg-indigo-600 text-white",
                    @current_category != category.id && "text-gray-700 bg-gray-200 hover:bg-gray-300"
                  ]}
                  id={category.id}
                >
                  <%= category.name %>
                </button>
              </.link>
              <.link patch={~p"/apps"} class="w-full sm:w-auto">
                <button class={[
                  "w-full sm:w-auto px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                  @current_category == nil && "bg-indigo-600 text-white",
                  @current_category != nil && "text-gray-700 bg-gray-200 hover:bg-gray-300"
                ]}>
                  All Categories
                </button>
              </.link>
            </div>

            <.dropdown_menu class="w-full sm:w-auto">
              <.dropdown_menu_trigger>
                <.button
                  aria-haspopup="true"
                  variant="outline"
                  class="w-full sm:w-auto items-center gap-2 dark:text-white"
                >
                  <.icon name="hero-bars-3-bottom-left" class="h-6 w-6" />
                  <span>Sort by</span>
                </.button>
              </.dropdown_menu_trigger>
              <.dropdown_menu_content align="center">
                <.menu>
                  <.menu_item class="justify-center">
                    <.link phx-click="sort_by_latest">
                      Latest
                    </.link>
                  </.menu_item>
                  <.menu_item class="justify-center">
                    <.link phx-click="sort_by_popularity">
                      Popular
                    </.link>
                  </.menu_item>
                </.menu>
              </.dropdown_menu_content>
            </.dropdown_menu>
          </div>
          <div class="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
            <.link
              :if={
                (@current_user && @current_user.role == :author) ||
                  (@current_user && @current_user.role == :admin)
              }
              patch={~p"/apps/new"}
              class="w-full sm:w-auto"
            >
              <.button class="w-full sm:w-auto">
                <.icon name="hero-pencil" class="mr-2 h-5 w-5" /> New App
              </.button>
            </.link>
            <div class="w-full sm:w-auto">
              <.button
                phx-click="open_search"
                class="w-full sm:w-auto text-gray-500 bg-white hover:ring-gray-500 hover:text-white dark:text-zinc-900 dark:hover:text-zinc-700 ring-gray-300 items-center gap-10 rounded-md px-3 text-sm ring-1 transition focus:[&:not(:focus-visible)]:outline-none"
              >
                <div class="flex items-center gap-2">
                  <Lucideicons.search class="h-4 w-4" />
                  <span class="flex-grow text-left">Find apps</span>
                </div>
                <kbd class="hidden sm:inline-flex text-3xs opacity-80">
                  <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
                </kbd>
              </.button>
            </div>
          </div>
        </div>
      </.header>

      <div class="grid grid-cols-1 gap-10 mt-4 md:grid-cols-2 lg:grid-cols-3">
        <div
          :for={{id, app} <- @streams.apps}
          id={id}
          class="card relative flex-shrink-0 overflow-hidden rounded-lg"
        >
          <.link navigate={~p"/apps/#{app}"}>
            <div class="relative overflow-hidden rounded-lg group">
              <img
                class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
                src={app.picture}
                alt={app.title}
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
            </div>
            <div
              <h4
              class="my-2 text-xl font-semibold text-gray-900 dark:text-zinc-100 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
            >
              <%= app.title %>
            </div>

            <p class="text-gray-500 dark:text-zinc-400 hover:text-gray-700 dark:hover:text-zinc-300 transition-colors">
              <%= app.description %>
            </p>
          </.link>
          <div>
            <div class="top-0 right-0 absolute m-4">
              <div :for={category <- @categories} class="flex flex-col">
                <.badge
                  :for={app_category <- app.categories_join_assoc}
                  :if={app_category.category_id == category.id}
                  variant="outline"
                  class="border-white bg-white text-white bg-opacity-35 mb-2 justify-center"
                >
                  <%= category.name %>
                </.badge>
              </div>
            </div>
            <.dropdown_menu
              :if={@current_user && @current_user.id == app.user_id}
              class="absolute top-0 flex m-4"
            >
              <.dropdown_menu_trigger>
                <.button
                  aria-haspopup="true"
                  size="icon"
                  variant="ghost"
                  class="text-white hover:text-zinc-700"
                >
                  <Lucideicons.ellipsis class="h-6 w-6" />
                  <span class="sr-only">Toggle menu</span>
                </.button>
              </.dropdown_menu_trigger>
              <.dropdown_menu_content align="start">
                <.menu>
                  <.menu_label>Actions</.menu_label>
                  <.menu_item>
                    <.link patch={~p"/apps/#{app}/edit"} class="flex items-center space-x-2">
                      <.icon name="hero-pencil-square" class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Edit</span>
                    </.link>
                  </.menu_item>
                  <.menu_item>
                    <.link
                      phx-click={JS.push("delete", value: %{id: app.id}) |> hide("##{id}")}
                      data-confirm="Are you sure?"
                      class="flex items-center space-x-2"
                    >
                      <.icon name="hero-trash" class="text-red-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Delete</span>
                    </.link>
                  </.menu_item>
                </.menu>
              </.dropdown_menu_content>
            </.dropdown_menu>
          </div>
        </div>
      </div>
    </section>

    <.modal :if={@live_action in [:new, :edit]} id="app-modal" show on_cancel={JS.patch(@patch)}>
      <.live_component
        module={AmboseliWeb.AppLive.FormComponent}
        id={(@app && @app.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        app={@app}
        patch={~p"/apps"}
      />
    </.modal>

    <.search_modal
      :if={@show_search_modal}
      id="search-notebook-modal"
      show
      on_cancel={JS.push("close_search")}
    >
      <.live_component
        module={AmboseliWeb.AppSearchLive.SearchComponent}
        id={:search}
        title={@page_title}
        current_user={@current_user}
        apps={@apps}
      />
    </.search_modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    categories = Amboseli.Catalog.Category.list_all!()

    {:ok,
     socket
     |> assign(:apps, [])
     |> stream(:apps, [])
     |> assign_new(:current_user, fn -> nil end)
     |> assign(:categories, categories)
     |> assign(:current_category, nil)
     |> assign(:show_search_modal, false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    patch = apply_patch(socket)

    app =
      Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :categories_join_assoc,
        :categories,
        :user
      ])

    socket
    |> assign(:page_title, "Edit App")
    |> assign(:app, app)
    |> assign(:patch, patch)
    |> stream(:apps, fetch_apps(socket, socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "New App")
    |> assign(:app, nil)
    |> assign(:patch, patch)
    |> stream(:apps, fetch_apps(socket, socket.assigns.current_user))
  end

  defp apply_action(socket, :index, _params) do
    current_user = socket.assigns.current_user
    apps = fetch_apps(socket, current_user)

    socket
    |> assign(:page_title, "Listing Apps")
    |> assign(:app, nil)
    |> assign(:current_category, nil)
    |> assign(:apps, apps)
    |> stream(:apps, apps, reset: true)
  end

  defp apply_action(socket, :filter_by_category, %{"category" => category_id}) do
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))
    apps = fetch_apps(socket, socket.assigns.current_user, category_id)

    socket
    |> assign(:page_title, "Category: #{category.name}")
    |> assign(:current_category, category_id)
    |> assign(:apps, apps)
    |> stream(:apps, apps, reset: true)
  end

  @impl true
  def handle_info({AmboseliWeb.AppLive.FormComponent, {:saved, app}}, socket) do
    categories = Amboseli.Catalog.Category.list_all!(actor: socket.assigns.current_user)

    app =
      app
      |> Ash.load!([
        :categories_join_assoc
      ])

    apps =
      fetch_apps(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> stream_insert(:apps, app, at: 0, reset: true)
     |> assign(:categories, categories)
     |> assign(:apps, apps)}
  end

  def handle_event("open_search", _params, socket) do
    apps = socket.assigns.apps
    current_category = socket.assigns.current_category

    {:noreply,
     socket
     |> assign(:page_title, "Search")
     |> stream(:apps, apps, reset: true)
     |> assign(:current_category, current_category)
     |> assign(:show_search_modal, true)}
  end

  def handle_event("close_search", _params, socket) do
    apps = socket.assigns.apps
    current_category = socket.assigns.current_category

    {:noreply,
     socket
     |> assign(:page_title, "Listing Apps")
     |> stream(:apps, apps, reset: true)
     |> assign(:current_category, current_category)
     |> assign(:show_search_modal, false)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    app = Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user)
    Ash.destroy!(app, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:apps, app)
     |> put_flash(:info, "App deleted successfully.")}
  end

  defp fetch_apps(_socket, current_user, category_id \\ nil) do
    apps =
      Amboseli.Catalog.App.list_public!(actor: current_user)
      |> Ash.load!([
        :categories_join_assoc,
        :categories,
        :user_email,
        :user
      ])

    # IO.inspect(apps, label: "fetched apps")

    case category_id do
      nil ->
        apps

      category_id ->
        Enum.filter(apps, fn app ->
          Enum.any?(app.categories_join_assoc, fn cat ->
            cat.category_id == category_id
          end)
        end)
    end
  end

  defp apply_patch(socket) do
    case socket.assigns.current_category do
      nil -> ~p"/apps"
      category_id -> ~p"/apps/category/#{category_id}"
    end
  end
end
