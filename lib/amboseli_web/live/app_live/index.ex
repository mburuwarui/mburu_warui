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
      </.header>
      <div class="m-auto max-w-3xl">
        <.header>
          <div class="flex flex-wrap gap-2 w-full sm:w-auto">
            <.link
              :for={category <- @categories}
              patch={~p"/apps/category/#{category.id}"}
              class="w-full sm:w-auto"
            >
              <button class={[
                "w-full sm:w-auto px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                @current_category == category.id && "bg-indigo-600 text-white",
                @current_category != category.id && "text-gray-700 bg-gray-200 hover:bg-gray-300"
              ]}>
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
          <:actions>
            <.link patch={~p"/apps/new"}>
              <.button>New App</.button>
            </.link>
          </:actions>
        </.header>
      </div>

      <div
        :for={{id, app} <- @streams.apps}
        class="grid grid-cols-1 gap-10 mt-10 md:grid-cols-2 lg:grid-cols-3"
        id={id}
      >
        <.link href={app.link} class="flex-shrink-0">
          <div class="relative overflow-hidden rounded-lg group">
            <img
              class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
              src={app.picture}
              alt={app.title}
            />
            <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
            </div>
          </div>

          <h4 class="my-2 text-xl font-semibold text-gray-900 dark:text-zinc-100 hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
            <%= app.title %>
          </h4>

          <p class="text-gray-500 dark:text-zinc-400 hover:text-gray-700 dark:hover:text-zinc-300 transition-colors">
            <%= app.description %>
          </p>
        </.link>
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    categories = Amboseli.Blog.Category.list_all!()

    {:ok,
     socket
     |> stream(:apps, Ash.read!(Amboseli.Catalog.App, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)
     |> assign(:categories, categories)
     |> assign(:current_category, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "Edit App")
    |> assign(:app, Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user))
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :new, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "New App")
    |> assign(:app, nil)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Apps")
    |> assign(:app, nil)
  end

  defp apply_action(socket, :filter_by_category, %{"category" => category_id}) do
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))
    notebooks = fetch_apps(socket.assigns.current_user, category_id)

    socket
    |> assign(:page_title, "Category: #{category.name}")
    |> assign(:current_category, category_id)
    |> assign(:notebooks, notebooks)
    |> stream(:notebooks, notebooks, reset: true)
  end

  @impl true
  def handle_info({AmboseliWeb.AppLive.FormComponent, {:saved, app}}, socket) do
    {:noreply, stream_insert(socket, :apps, app)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    app = Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user)
    Ash.destroy!(app, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :apps, app)}
  end

  defp fetch_apps(_socket, current_user, category_id \\ nil) do
    apps =
      Amboseli.Catalog.App.list_public!(actor: current_user)
      |> Ash.load!([
        :categories_join_assoc,
        :categories,
        :user_email
      ])

    # IO.inspect(notebooks, label: "fetched notebooks")

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
