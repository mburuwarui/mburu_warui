defmodule AmboseliWeb.NotebookLive.Index do
  use AmboseliWeb, :blog_view

  on_mount {AmboseliWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <section class="container px-6 py-8 mx-auto lg:py-16">
      <.header>
        <div class="w-full text-center mb-4 sm:mb-10">
          <h1 class="text-4xl font-extrabold dark:text-white">Notebooks</h1>
        </div>

        <div class="py-4 flex sm:flex-row flex-col justify-between gap-4 items-center">
          <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <div class="flex flex-wrap gap-2 w-full sm:w-auto">
              <.link
                :for={category <- @categories}
                patch={~p"/notebooks/category/#{category.id}"}
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
              <.link patch={~p"/notebooks"} class="w-full sm:w-auto">
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
              patch={~p"/notebooks/new"}
              class="w-full sm:w-auto"
            >
              <.button class="w-full sm:w-auto">
                <.icon name="hero-pencil" class="mr-2 h-5 w-5" /> New Notebook
              </.button>
            </.link>
            <.button
              phx-click={show_modal("notebook-search")}
              class="w-full sm:w-auto text-gray-500 bg-white hover:ring-gray-500 hover:text-white dark:text-zinc-900 dark:hover:text-zinc-700 ring-gray-300 items-center gap-10 rounded-md px-3 text-sm ring-1 transition focus:[&:not(:focus-visible)]:outline-none"
            >
              <div class="flex items-center gap-2">
                <Lucideicons.search class="h-4 w-4" />
                <span class="flex-grow text-left">Find notebooks</span>
              </div>
              <kbd class="hidden sm:inline-flex text-3xs opacity-80">
                <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
              </kbd>
            </.button>
          </div>
        </div>
      </.header>
      <div
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4"
        phx-update="stream"
        id="notebooks"
      >
        <div
          :for={{id, notebook} <- @streams.notebooks}
          class="card flex flex-col h-full group"
          id={id}
        >
          <div class="relative flex-shrink-0 overflow-hidden rounded-lg">
            <.link :if={Enum.any?(notebook.pictures)} navigate={~p"/notebooks/#{notebook}"}>
              <img
                class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110 group-hover:shadow-xl"
                src={Enum.at(notebook.pictures, -1).url}
                alt=""
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
            </.link>
            <div class="top-0 right-0 absolute m-4">
              <div :for={category <- @categories} class="flex flex-col">
                <.badge
                  :for={notebook_category <- notebook.categories_join_assoc}
                  :if={notebook_category.category_id == category.id}
                  variant="outline"
                  class="border-white bg-white text-white bg-opacity-35 mb-2 justify-center"
                >
                  <%= category.name %>
                </.badge>
              </div>
            </div>
            <.dropdown_menu
              :if={@current_user && @current_user.id == notebook.user_id}
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
                    <.link patch={~p"/notebooks/#{notebook}/edit"} class="flex items-center space-x-2">
                      <.icon name="hero-pencil-square" class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Edit</span>
                    </.link>
                  </.menu_item>
                  <.menu_item>
                    <.link
                      phx-click={JS.push("delete", value: %{id: notebook.id}) |> hide("##{id}")}
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
            <div
              :for={profile <- @profiles}
              :if={profile && profile.user_id == notebook.user_id}
              class="absolute bottom-0 flex p-3 bg-white dark:bg-gray-900"
              a
            >
              <img
                class="object-cover object-center w-10 h-10 rounded-full"
                src={profile.avatar}
                alt=""
              />
              <div class="mx-4">
                <h1 class="text-sm text-gray-700 dark:text-gray-200">
                  <%= profile.first_name %> <%= profile.last_name %>
                </h1>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  <%= profile.occupation %>
                </p>
              </div>
            </div>
          </div>
          <div class="flex justify-between mt-4 mr-4 ">
            <div class="justify-start flex flex-row gap-5 items-center text-sm text-zinc-400">
              <div :if={notebook.page_views > 0} class=" flex gap-1">
                <Lucideicons.eye class="h-4 w-4" /> <%= notebook.page_views %>
              </div>
              <div :if={notebook.like_count > 0} class=" flex gap-1 items-center">
                <Lucideicons.heart class="h-4 w-4" /> <%= notebook.like_count %>
              </div>
              <div :if={notebook.bookmark_count > 0} class=" flex gap-1 items-center">
                <.icon name="hero-bookmark" class="h-4 w-4" /> <%= notebook.bookmark_count %>
              </div>
              <div :if={notebook.comment_count > 0} class=" flex gap-1 items-center">
                <.icon name="hero-chat-bubble-oval-left" class="w-4 h-4" /> <%= notebook.comment_count %>
              </div>
            </div>
            <div class="flex gap-4">
              <%= if @current_user do %>
                <%= if notebook.bookmarked_by_user do %>
                  <button phx-click="unbookmark" phx-value-id={notebook.id}>
                    <.icon name="hero-bookmark-solid" class="text-blue-400" />
                  </button>
                <% else %>
                  <button phx-click="bookmark" phx-value-id={notebook.id}>
                    <.icon name="hero-bookmark" class="text-blue-500" />
                  </button>
                <% end %>
              <% else %>
                <.link phx-click={show_modal("sign-in")}>
                  <.icon name="hero-bookmark" class="text-blue-500" />
                </.link>
              <% end %>
            </div>
          </div>
          <div class="flex flex-col flex-grow relative pt-2 mb-4">
            <div class="text-xs text-zinc-500">
              <%= Calendar.strftime(notebook.inserted_at, "%B %d, %Y") %>
            </div>
            <div class="h-20 mb-2">
              <!-- Fixed height for title area -->
              <.link navigate={~p"/notebooks/#{notebook}"}>
                <h1 class="text-xl font-semibold text-gray-800 dark:text-white line-clamp-2">
                  <%= notebook.title %>
                </h1>
              </.link>
            </div>

            <hr class="w-32 absolute top-[110px] left-0 border-t-1 border-blue-500" />
            <%!--   <p class="text-sm text-gray-500 dark:text-gray-400 flex-grow mt-4"> --%>
            <%!--     <%= truncate(notebook.body, 20) |> MDEx.to_html!() |> raw() %> --%>
            <%!--   </p> --%>
            <%!--   <.link --%>
            <%!--     navigate={~p"/notebooks/#{notebook}"} --%>
            <%!--     class="inline-block mt-2 text-blue-500 underline hover:text-blue-400" --%>
            <%!--   > --%>
            <%!--     Read more --%>
            <%!--   </.link> --%>
          </div>
        </div>
      </div>
    </section>

    <.modal :if={@live_action in [:new, :edit]} id="notebook-modal" show on_cancel={JS.patch(@patch)}>
      <.live_component
        module={AmboseliWeb.NotebookLive.FormComponent}
        id={(@notebook && @notebook.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        notebook={@notebook}
        patch={~p"/notebooks"}
      />
    </.modal>

    <.search_modal id="notebook-search" on_cancel={hide_modal("notebook-search")}>
      <.live_component
        module={AmboseliWeb.NotebookLive.SearchComponent}
        id={:search}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        notebooks={@notebooks}
        patch={~p"/notebooks"}
      />
    </.search_modal>

    <.sign_modal id="sign-in" on_cancel={hide_modal("sign-in")}>
      <div class="flex flex-col gap-10">
        <img src={~p"/images/logo.jpg"} class="w-32 h-32 mx-auto rounded-full" />
        <h2 class="text-xl font-semibold text-gray-800 dark:text-white text-center">
          Hey, 👋 sign up or sign in to interact.
        </h2>
        <.link patch={~p"/sign-in"}>
          <.button class="w-full">
            <.icon name="hero-user-circle" class="w-5 h-5 mr-2" /> Sign in with Amboseli
          </.button>
        </.link>
      </div>
    </.sign_modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    categories = Amboseli.Blog.Category.list_all!()

    {:ok,
     socket
     |> assign(:notebooks, [])
     |> stream(:notebooks, [])
     |> assign_new(:current_user, fn -> nil end)
     |> assign(:current_category, nil)
     |> assign(:profiles, [])
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    patch = apply_patch(socket)

    notebook =
      Ash.get!(Amboseli.Blog.Notebook, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :categories_join_assoc,
        :categories,
        :user,
        :pictures
      ])

    socket
    |> assign(:page_title, "Edit Notebook")
    |> assign(:notebook, notebook)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :new, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "New Notebook")
    |> assign(:notebook, nil)
    |> assign(:patch, patch)
    |> stream(:notebooks, fetch_notebooks(socket, socket.assigns.current_user))
  end

  defp apply_action(socket, :index, _params) do
    current_user = socket.assigns.current_user
    notebooks = fetch_notebooks(socket, current_user)

    profiles =
      Enum.map(notebooks, & &1.user)
      |> Ash.load!([:profile])
      |> Enum.map(& &1.profile)

    IO.inspect(profiles, label: "profiles")

    socket
    |> assign(:page_title, "Listing Notebooks")
    |> assign(:notebook, nil)
    |> assign(:profiles, profiles)
    |> assign(:current_category, nil)
    |> assign(:notebooks, notebooks)
    |> stream(:notebooks, notebooks, reset: true)
  end

  defp apply_action(socket, :filter_by_category, %{"category" => category_id}) do
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))
    notebooks = fetch_notebooks(socket, socket.assigns.current_user, category_id)

    socket
    |> assign(:page_title, "Category: #{category.name}")
    |> assign(:current_category, category_id)
    |> assign(:notebooks, notebooks)
    |> stream(:notebooks, notebooks, reset: true)
  end

  @impl true
  def handle_info({AmboseliWeb.NotebookLive.FormComponent, {:saved, updated_notebook}}, socket) do
    categories = Amboseli.Blog.Category.list_all!(actor: socket.assigns.current_user)

    notebook =
      updated_notebook
      |> Ash.load!([
        :categories_join_assoc,
        :like_count,
        :page_views,
        :bookmark_count,
        :comment_count,
        :pictures,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    notebooks =
      fetch_notebooks(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> stream_insert(:notebooks, notebook, at: 0, reset: true)
     |> assign(:categories, categories)
     |> assign(:notebooks, notebooks)}
  end

  @impl true
  def handle_event("bookmark", %{"id" => id}, socket) do
    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Amboseli.Blog.Notebook.bookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, true)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :pictures,
        :categories_join_assoc,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    notebooks =
      fetch_notebooks(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> assign(:notebooks, notebooks)
     |> stream_insert(:notebooks, notebook, reset: true)}
  end

  def handle_event("unbookmark", %{"id" => id}, socket) do
    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Amboseli.Blog.Notebook.unbookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, false)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :pictures,
        :categories_join_assoc,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    notebooks =
      fetch_notebooks(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> assign(:notebooks, notebooks)
     |> stream_insert(:notebooks, notebook, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    notebook =
      Ash.get!(Amboseli.Blog.Notebook, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :likes,
        :comments,
        :bookmarks,
        :categories_join_assoc,
        :pictures,
        :user
      ])

    Ash.destroy!(notebook, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:notebooks, notebook)
     |> put_flash(:info, "Notebook deleted successfully.")}
  end

  @impl true
  def handle_event("sort_by_popularity", _params, socket) do
    notebooks =
      fetch_notebooks(socket, socket.assigns.current_user, socket.assigns.current_category)
      |> Enum.sort_by(& &1.popularity_score, &>=/2)

    {:noreply,
     socket
     |> assign(:notebooks, notebooks)
     |> stream(:notebooks, notebooks, reset: true)}
  end

  def handle_event("sort_by_latest", _params, socket) do
    notebooks =
      fetch_notebooks(socket, socket.assigns.current_user, socket.assigns.current_category)

    # |> Enum.sort_by(& &1.inserted_at, &>=/2)

    {:noreply,
     socket
     |> assign(:notebooks, notebooks)
     |> stream(:notebooks, notebooks, reset: true)}
  end

  defp fetch_notebooks(socket, current_user, category_id \\ nil) do
    notebooks =
      Amboseli.Blog.Notebook.list_public!(actor: current_user)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :popularity_score,
        :reading_time,
        :likes,
        :comments,
        :bookmarks,
        :pictures,
        :categories_join_assoc,
        :categories,
        :user,
        liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id},
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    # IO.inspect(notebooks, label: "fetched notebooks")

    case category_id do
      nil ->
        notebooks

      category_id ->
        Enum.filter(notebooks, fn notebook ->
          Enum.any?(notebook.categories_join_assoc, fn cat ->
            cat.category_id == category_id
          end)
        end)
    end
  end

  def truncate(text, max_words) do
    text
    |> String.split()
    |> Enum.take(max_words)
    |> Enum.join(" ")
    |> Kernel.<>("...")
  end

  defp apply_patch(socket) do
    case socket.assigns.current_category do
      nil -> ~p"/notebooks"
      category_id -> ~p"/notebooks/category/#{category_id}"
    end
  end
end
