defmodule AmboseliWeb.NotebookLive.Show do
  use AmboseliWeb, :blog_view

  on_mount {AmboseliWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row justify-center">
      <div class="lg:w-1/5 flex justify-end items-start"></div>
      <div class="lg:w-3/5">
        <.header class="max-w-3xl mx-auto">
          <div class="flex justify-between items-baseline w-full">
            <div class="px-4 py-2 hover:text-yellow-900">
              <.back navigate={~p"/notebooks"}>Back to notebooks</.back>
            </div>
            <%= if @current_user == @notebook.user do %>
              <.link patch={~p"/notebooks/#{@notebook}/show/edit"} phx-click={JS.push_focus()}>
                <.button>
                  <.icon name="hero-pencil-square" class="mr-2 h-5 w-5" /> Edit Notebook
                </.button>
              </.link>
            <% end %>
          </div>
        </.header>
        <div class="max-w-3xl mx-auto py-8">
          <div :if={Enum.any?(@notebook.pictures)} class="mb-8">
            <img
              src={Enum.at(@notebook.pictures, -1).url}
              alt={@notebook.title}
              class="w-full h-64 object-cover rounded-lg shadow-md"
            />
          </div>

          <h1 class="text-4xl font-extrabold text-center text-gray-900 my-14 dark:text-white">
            <%= @notebook.title %>
          </h1>

          <div class="flex justify-between items-end">
            <div :if={@profile && @profile.user_id == @notebook.user_id} class="flex">
              <img
                class="object-cover object-center w-10 h-10 rounded-full"
                src={@profile.avatar}
                alt=""
              />
              <div class="mx-4">
                <h1 class="text-sm text-gray-700 dark:text-gray-200">
                  <%= @profile.first_name %> <%= @profile.last_name %>
                </h1>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  <%= @profile.occupation %>
                </p>
              </div>
            </div>

            <div class="text-sm text-gray-700 dark:text-gray-200 flex flex-col items-end">
              <%= @notebook.reading_time %> min read
              <div
                phx-hook="LocalTime"
                id={"inserted_at-#{@notebook.inserted_at}"}
                class="hidden md:block invisible text-sm text-gray-700 dark:text-gray-200"
              >
                <%= DateTime.to_string(@notebook.inserted_at) %>
              </div>
            </div>
          </div>

          <.notebook_actions
            notebook={@notebook}
            current_user={@current_user}
            current_uri={@current_uri}
          />

          <div class="prose prose-lg max-w-none mb-8 dark:prose-invert">
            <%= MDEx.to_html!(@notebook.body,
              features: [syntax_highlight_theme: "dracula"],
              extension: [
                strikethrough: true,
                tagfilter: true,
                table: true,
                autolink: true,
                tasklist: true,
                header_ids: "notebook-",
                footnotes: true,
                shortcodes: true
              ],
              parse: [
                smart: true,
                relaxed_tasklist_matching: true,
                relaxed_autolinks: true
              ],
              render: [
                github_pre_lang: true,
                unsafe_: true
              ]
            )
            |> raw() %>
          </div>

          <.separator class="my-20" />

          <div class="my-4">
            <h2 class="text-xl font-semibold mb-4">Categories</h2>
            <div class="flex flex-wrap gap-2">
              <%= for category <- @notebook.categories_join_assoc do %>
                <%= for notebook_category <- @categories do %>
                  <%= if category.category_id == notebook_category.id do %>
                    <.link navigate={~p"/notebooks/category/#{category.category_id}"}>
                      <.badge variant="outline" class="mb-2 justify-center">
                        <%= notebook_category.name %>
                      </.badge>
                    </.link>
                  <% end %>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>

        <div class="max-w-3xl mx-auto">
          <.notebook_actions
            notebook={@notebook}
            current_user={@current_user}
            current_uri={@current_uri}
          />
        </div>

        <div class="flex my-8 justify-between max-w-3xl mx-auto items-end">
          <div class="">
            <%= @notebook.comment_count %>
            <%= if @notebook.comment_count == 1 do %>
              Comment
            <% else %>
              Comments
            <% end %>
          </div>

          <%= if @current_user do %>
            <.link patch={~p"/notebooks/#{@notebook}/comments/new"} phx-click={JS.push_focus()}>
              <.button>New Comment</.button>
            </.link>
          <% else %>
            <.button phx-click={show_modal("sign-in")}>New Comment</.button>
          <% end %>
        </div>

        <.comment_tree
          stream={@streams.comments}
          current_user={@current_user}
          notebook={@notebook}
          profile={@profile}
        />

        <div class="max-w-3xl mx-auto py-8 hover:text-yellow-900">
          <.back navigate={~p"/notebooks"}>Back to notebooks</.back>
        </div>
      </div>
      <div class="lg:w-1/5 hidden lg:block">
        <div class="sticky top-60 pl-4">
          <h2 class="text-2xl font-bold mb-4">Table of Contents</h2>
          <ul class="toc-list" id="toc-list" phx-hook="TableOfContents">
            <!-- TOC items will be dynamically inserted here -->
          </ul>
        </div>
      </div>
    </div>

    <.modal
      :if={@live_action == :edit}
      id="notebook-modal"
      show
      on_cancel={JS.patch(~p"/notebooks/#{@notebook}")}
    >
      <.live_component
        module={AmboseliWeb.NotebookLive.FormComponent}
        id={@notebook.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        notebook={@notebook}
        patch={~p"/notebooks/#{@notebook}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_comment, :edit_comment, :new_comment_child]}
      id="comment-modal"
      show
      on_cancel={JS.patch(~p"/notebooks/#{@notebook}")}
    >
      <.live_component
        module={AmboseliWeb.CommentLive.FormComponent}
        id={(@comment && @comment.id) || :new_comment}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        notebook={@notebook}
        comment={@comment}
        parent_comment={@parent_comment}
        patch={~p"/notebooks/#{@notebook}"}
      />
    </.modal>

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
    profiles = Amboseli.Accounts.Profile.read!(actor: socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:profiles, profiles)
     |> assign(:show_sign_modal, false)
     |> stream(:comments, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    increment_page_view(socket, id)

    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!(notebook_fields(socket))

    comments =
      notebook.comments
      |> Enum.map(fn comment ->
        comment
        |> Ash.load!([:child_comments, :user, :parent_comment])
      end)

    current_user = socket.assigns.current_user

    categories = Amboseli.Blog.Category.list_all!(actor: current_user)

    user =
      notebook.user
      |> Ash.load!([:profile])

    socket
    |> assign(:page_title, "Show Notebook")
    |> assign(:current_notebook_id, id)
    |> assign(:notebook, notebook)
    |> assign(:comments, comments)
    |> stream(:comments, comments, reset: true)
    |> assign(:categories, categories)
    |> assign(:profile, user.profile)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user

    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(id, actor: current_user)
      |> Ash.load!(notebook_fields(socket))

    categories = Amboseli.Blog.Category.list_all!(actor: current_user)

    socket
    |> assign(:page_title, "Edit Notebook")
    |> stream(:comments, notebook.comments)
    |> assign(:notebook, notebook)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :new_comment, %{"id" => notebook_id}) do
    current_user = socket.assigns.current_user

    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(notebook_id, actor: current_user)
      |> Ash.load!(notebook_fields(socket))

    categories = Amboseli.Blog.Category.list_all!(actor: current_user)

    comments = notebook.comments

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> assign(:parent_comment, nil)
    |> assign(:notebook, notebook)
    |> stream(:comments, comments)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :new_comment_child, %{"c_id" => id}) do
    current_user = socket.assigns.current_user

    parent_comment =
      Amboseli.Blog.Comment
      |> Ash.get!(id, actor: current_user)
      |> Ash.load!([:notebook, :child_comments, :parent_comment])

    categories = Amboseli.Blog.Category.list_all!(actor: current_user)

    notebook =
      parent_comment.notebook
      |> Ash.load!(notebook_fields(socket))

    comments = notebook.comments

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> stream(:comments, comments)
    |> assign(:parent_comment, parent_comment)
    |> assign(:notebook, notebook)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :edit_comment, %{"c_id" => id}) do
    comment =
      Amboseli.Blog.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:notebook, :parent_comment])

    notebook =
      comment.notebook
      |> Ash.load!(notebook_fields(socket))

    socket
    |> assign(:page_title, "Edit Comment")
    |> stream(:comments, notebook.comments)
    |> assign(:comment, comment)
    |> assign(:parent_comment, nil)
    |> assign(:notebook, notebook)
  end

  @impl true
  def handle_info({AmboseliWeb.CommentLive.FormComponent, {:saved, comment}}, socket) do
    categories = Amboseli.Blog.Category.list_all!(actor: socket.assigns.current_user)

    comment =
      comment |> Ash.load!([:user, :notebook, :child_comments, :parent_comment])

    notebook = comment.notebook |> Ash.load!([:comments])

    {:noreply,
     socket
     |> stream_insert(:comments, comment)
     |> assign(comments: notebook.comments)
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_info({AmboseliWeb.NotebookLive.FormComponent, {:saved, updated_notebook}}, socket) do
    categories = Amboseli.Blog.Category.list_all!(actor: socket.assigns.current_user)

    notebook =
      updated_notebook
      |> Ash.load!(notebook_fields(socket))

    comments = notebook.comments

    {:noreply,
     socket
     |> stream(:comments, comments)
     |> assign(:categories, categories)
     |> assign(:notebook, notebook)}
  end

  @impl true
  def handle_event("like", _params, socket) do
    notebook =
      socket.assigns.notebook
      |> Amboseli.Blog.Notebook.like!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, true)
      |> Ash.load!([:like_count, :comments, :popularity_score, :comment_count])

    comments = notebook.comments

    {:noreply,
     socket
     |> assign(:notebook, notebook)
     |> stream(:comments, comments)}
  end

  def handle_event("dislike", _params, socket) do
    notebook =
      socket.assigns.notebook
      |> Amboseli.Blog.Notebook.dislike!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, false)
      |> Ash.load!([:like_count, :comments, :popularity_score, :comment_count])

    comments = notebook.comments

    {:noreply,
     socket
     |> assign(:notebook, notebook)
     |> stream(:comments, comments)}
  end

  @impl true
  def handle_event("bookmark", _params, socket) do
    notebook =
      socket.assigns.notebook
      |> Amboseli.Blog.Notebook.bookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, true)
      |> Ash.load!([:bookmark_count, :comments, :popularity_score])

    comments = notebook.comments

    {:noreply,
     socket
     |> assign(:notebook, notebook)
     |> stream(:comments, comments)}
  end

  def handle_event("unbookmark", _params, socket) do
    notebook =
      socket.assigns.notebook
      |> Amboseli.Blog.Notebook.unbookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, false)
      |> Ash.load!([:bookmark_count, :comments, :popularity_score])

    comments = notebook.comments

    {:noreply,
     socket
     |> assign(:notebook, notebook)
     |> stream(:comments, comments)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comment =
      Ash.get!(Amboseli.Blog.Comment, id, actor: socket.assigns.current_user)
      |> Ash.load!([:notebook])

    Ash.destroy!(comment, actor: socket.assigns.current_user)

    notebook = comment.notebook |> Ash.load!(notebook_fields(socket))

    {:noreply,
     socket
     |> stream_delete(:comments, comment)
     |> assign(:comments, notebook.comments)
     |> assign(:notebook, notebook)
     |> put_flash(:info, "Comment deleted successfully.")}
  end

  def notebook_fields(socket) do
    [
      :like_count,
      :comment_count,
      :bookmark_count,
      :reading_time,
      :popularity_score,
      :comments,
      :pictures,
      :bookmarks,
      :categories,
      :categories_join_assoc,
      :likes,
      :user,
      liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id},
      bookmarked_by_user: %{
        user_id: socket.assigns.current_user && socket.assigns.current_user.id
      }
    ]
  end

  defp increment_page_view(socket, id) do
    # Only increment page views if this is a different notebook
    notebook =
      Amboseli.Blog.Notebook
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!(notebook_fields(socket))

    # Get the previous notebook ID from socket assigns
    previous_notebook_id = Map.get(socket.assigns, :current_notebook_id)

    if previous_notebook_id != id and connected?(socket) do
      Amboseli.Blog.Notebook.inc_page_views!(notebook,
        actor: socket.assigns.current_user,
        authorize?: false
      )
    end

    {:noreply, socket}
  end

  defp comment_tree(assigns) do
    ~H"""
    <div class="space-y-4" phx-update="stream" id="comments">
      <%= for {id, comment} <- @stream do %>
        <%= if is_nil(comment.parent_comment_id) do %>
          <%= render_comment(assigns, id, comment) %>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp render_comment(assigns, id, comment) do
    assigns = assign(assigns, :comment, comment)
    assigns = assign(assigns, :id, id)

    ~H"""
    <.comment
      id={@id}
      comment={@comment}
      current_user={@current_user}
      notebook={@notebook}
      profile={@profile}
    >
      <div phx-update="stream" id="comments">
        <%= for {child_id, child_comment} <- @stream do %>
          <%= if child_comment.parent_comment_id == @comment.id do %>
            <%= render_comment(assigns, child_id, child_comment) %>
          <% end %>
        <% end %>
      </div>
    </.comment>
    """
  end

  defp comment(assigns) do
    ~H"""
    <div
      id={@id}
      class="border-l-2 border-gray-200 pl-2 sm:pl-4 flex flex-col sm:flex-row items-start sm:space-y-0 sm:space-x-4 mt-4 max-w-3xl mx-auto"
    >
      <img
        :if={@comment.user_id == @profile.user_id}
        class="object-cover object-center w-10 h-10 sm:w-12 sm:h-12 rounded-full"
        src={@profile.avatar}
        alt=""
      />
      <div class="flex-grow w-full sm:w-auto">
        <div class="flex sm:flex-row sm:items-center items-center justify-between mb-2">
          <span :if={@comment.user_id == @profile.user_id} class="font-semibold text-sm sm:text-base">
            <%= @profile.first_name %>
          </span>
          <div :if={@current_user} class="flex items-center space-x-2 mt-2 sm:mt-0">
            <.link
              patch={~p"/notebooks/#{@notebook}/comments/#{@comment}/new"}
              phx-click={JS.push_focus()}
            >
              <.tooltip>
                <Lucideicons.reply class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                <.tooltip_content class="bg-primary text-white dark:text-zinc-700" side="left">
                  <p>Reply</p>
                </.tooltip_content>
              </.tooltip>
            </.link>
            <.dropdown_menu :if={@current_user && @current_user.id == @comment.user_id}>
              <.dropdown_menu_trigger>
                <.button aria-haspopup="true" size="icon" variant="ghost" class="p-1 sm:p-2">
                  <Lucideicons.ellipsis class="h-4 w-4" />
                  <span class="sr-only">Toggle menu</span>
                </.button>
              </.dropdown_menu_trigger>
              <.dropdown_menu_content align="end">
                <.menu>
                  <.menu_label>Actions</.menu_label>
                  <.menu_item>
                    <.link
                      patch={~p"/notebooks/#{@notebook}/comments/#{@comment}/edit"}
                      phx-click={JS.push_focus()}
                      class="flex items-center space-x-2"
                    >
                      <.icon name="hero-pencil-square" class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Edit</span>
                    </.link>
                  </.menu_item>
                  <.menu_item>
                    <.link
                      data-confirm="Are you sure?"
                      phx-click={JS.push("delete", value: %{id: @comment.id})}
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
        <p class="text-xs sm:text-sm text-gray-700 dark:text-gray-200"><%= @comment.content %></p>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp notebook_actions(assigns) do
    ~H"""
    <.separator class="my-2" />

    <div class="flex justify-between mx-2 gap-4">
      <div class="flex gap-4 items-center">
        <%= if @current_user do %>
          <div class="flex gap-1 items-end">
            <%= if @notebook.liked_by_user do %>
              <button phx-click="dislike" phx-value-id={@notebook.id}>
                <.icon name="hero-heart-solid" class="text-red-400" />
              </button>
            <% else %>
              <button phx-click="like" phx-value-id={@notebook.id}>
                <.icon name="hero-heart" class="text-red-300" />
              </button>
            <% end %>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              <%= @notebook.like_count %>
            </p>
          </div>
          <div class="flex gap-1 items-end">
            <%= if @notebook.bookmarked_by_user do %>
              <button phx-click="unbookmark" phx-value-id={@notebook.id}>
                <.icon name="hero-bookmark-solid" class="text-blue-400" />
              </button>
            <% else %>
              <button phx-click="bookmark" phx-value-id={@notebook.id}>
                <.icon name="hero-bookmark" class="text-blue-500" />
              </button>
            <% end %>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              <%= @notebook.bookmark_count %>
            </p>
          </div>
        <% else %>
          <div class="flex gap-1 items-end">
            <.link phx-click={show_modal("sign-in")}>
              <.icon name="hero-heart" class="text-red-500" />
            </.link>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              <%= @notebook.like_count %>
            </p>
          </div>
          <div class="flex gap-1 items-end">
            <.link phx-click={show_modal("sign-in")}>
              <.icon name="hero-bookmark" class="text-blue-500" />
            </.link>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              <%= @notebook.bookmark_count %>
            </p>
          </div>
        <% end %>
        <div
          :if={@notebook.page_views > 0}
          class="flex gap-1 text-sm text-gray-500 dark:text-gray-200 items-end"
        >
          <.icon name="hero-eye" class="text-yellow-500" />
          <%= @notebook.page_views %>
        </div>
      </div>

      <div class="flex gap-4 items-center">
        <a
          href={"https://livebook.dev/run?url=#{URI.encode_www_form(@notebook.livemd_url)}"}
          target="_blank"
          rel="noopener noreferrer"
        >
          <img src="https://livebook.dev/badge/v1/gray.svg" alt="Run in Livebook" />
        </a>
        <.dropdown_menu>
          <.dropdown_menu_trigger>
            <.tooltip>
              <.icon name="hero-arrow-up-on-square" class="text-yellow-500 cursor-pointer" />
              <.tooltip_content class="bg-primary text-white dark:text-zinc-900">
                <p>Share</p>
              </.tooltip_content>
            </.tooltip>
          </.dropdown_menu_trigger>
          <.dropdown_menu_content side="top" align="end">
            <.menu class="">
              <.menu_label>Share</.menu_label>
              <.menu_separator />
              <.menu_group>
                <.menu_item>
                  <a
                    href={"https://twitter.com/intent/tweet?url=#{URI.encode_www_form("#{AmboseliWeb.Endpoint.url()}#{@current_uri}")}&text=#{URI.encode_www_form(@notebook.title)}"}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center"
                  >
                    <img src="/images/x.svg" class="mr-2 h-4 w-4" />
                    <span>Twitter</span>
                  </a>
                </.menu_item>
                <.menu_item>
                  <a
                    href={"https://www.linkedin.com/shareArticle?mini=true&url=#{URI.encode_www_form("#{AmboseliWeb.Endpoint.url()}#{@current_uri}")}&title=#{URI.encode_www_form(@notebook.title)}"}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center"
                  >
                    <img src="/images/linkedin.svg" class="mr-2 h-4 w-4" />
                    <span>LinkedIn</span>
                  </a>
                </.menu_item>
                <.menu_item>
                  <a
                    href={"https://www.reddit.com/submit?url=#{URI.encode_www_form("#{AmboseliWeb.Endpoint.url()}#{@current_uri}")}&title=#{URI.encode_www_form(@notebook.title)}"}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center"
                  >
                    <img src="/images/reddit.svg" class="mr-2 h-4 w-4" />
                    <span>Reddit</span>
                  </a>
                </.menu_item>
                <.menu_item>
                  <a
                    href={"https://www.facebook.com/sharer/sharer.php?u=#{URI.encode_www_form("#{AmboseliWeb.Endpoint.url()}#{@current_uri}")}"}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center"
                  >
                    <img src="/images/facebook.svg" class="mr-2 h-4 w-4" />
                    <span>Facebook</span>
                  </a>
                </.menu_item>
                <.menu_item>
                  <a
                    href={"https://api.whatsapp.com/send?text=#{URI.encode_www_form(@notebook.title)}%20#{URI.encode_www_form("#{AmboseliWeb.Endpoint.url()}#{@current_uri}")}"}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center"
                  >
                    <img src="/images/whatsapp.svg" class="mr-2 h-4 w-4" />
                    <span>WhatsApp</span>
                  </a>
                </.menu_item>
              </.menu_group>
              <.menu_separator />
              <.menu_group>
                <.menu_item>
                  <button id="copy" phx-hook="Copy" data-to="#permalink-url" class="flex items-center">
                    <.icon name="hero-link" class="mr-2 h-4 w-4" />
                    <span>Permalink</span>
                  </button>
                </.menu_item>
                <input
                  type="text"
                  id="permalink-url"
                  value={"#{AmboseliWeb.Endpoint.url()}#{@current_uri}"}
                  class="hidden"
                />
              </.menu_group>
            </.menu>
          </.dropdown_menu_content>
        </.dropdown_menu>
      </div>
    </div>

    <.separator class="mt-2 mb-20" />
    """
  end
end
