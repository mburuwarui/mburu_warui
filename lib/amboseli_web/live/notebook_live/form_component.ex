defmodule AmboseliWeb.NotebookLive.FormComponent do
  use AmboseliWeb, :live_component

  on_mount {AmboseliWeb.LiveUserAuth, :live_user_required}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage notebook records in your database.</:subtitle>
      </.header>

      <div :if={@continue_notice} class="my-2 p-2 ring-1 rounded-lg bg-emerald-50 ring-emerald-500">
        <%= @continue_notice %>
      </div>

      <.simple_form
        for={@form}
        id="notebook-form"
        phx-target={@myself}
        phx-change="validate"
        phx-auto-recover="recover"
        phx-submit="save"
      >
        <.input field={@form[:title]} label="Title" required />
        <.input field={@form[:body]} type="textarea" label="Body" required />
        <.input
          field={@form[:visibility]}
          type="select"
          options={[:public, :private]}
          label="Visibility"
        />

        <div class="space-y-2">
          <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-200">Categories</label>
          <%= for category <- @available_categories do %>
            <div class="flex items-center">
              <.input
                field={@form[:categories]}
                type="checkbox"
                id={"notebook-categories-#{category.name}"}
                checked={category.name in @selected_categories}
                label={category.name}
                phx-click="toggle_category"
                phx-value-name={category.name}
                phx-target={@myself}
              />
            </div>
          <% end %>
        </div>

        <.live_file_input upload={@uploads.notebook_picture} />
        <%= for entry <- @uploads.notebook_picture.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

            <%= for err <- upload_errors(@uploads.notebook_picture, entry) do %>
              <p class="alert alert-danger"><%= inspect(err) %></p>
            <% end %>
          </article>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Notebook</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_categories, Amboseli.Blog.Category.list_all!())
     |> assign(:selected_categories, get_selected_categories(assigns.notebook))
     |> assign(:uploaded_files, [])
     |> allow_upload(:notebook_picture,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       external: &presign_picture_upload/2
     )
     |> assign(:continue_notice, nil)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"notebook" => notebook_params}, socket) do
    categories =
      case Map.get(notebook_params, "categories") do
        nil -> []
        categories when is_list(categories) -> categories
        categories when is_binary(categories) -> [categories]
        _ -> []
      end
      |> Enum.map(fn category ->
        if is_binary(category) do
          %{name: category}
        else
          category
        end
      end)

    notebook_params =
      notebook_params
      |> Map.put("categories", categories)

    form =
      socket.assigns.form
      |> AshPhoenix.Form.validate(notebook_params)
      |> AshPhoenix.Form.update_options(fn options ->
        Keyword.put(options, :selected_categories, socket.assigns.selected_categories)
      end)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("recover", %{"notebook" => notebook_params}, socket) do
    categories =
      case Map.get(notebook_params, "categories") do
        nil -> []
        categories when is_list(categories) -> categories
        categories when is_binary(categories) -> [categories]
        _ -> []
      end
      |> Enum.map(fn category ->
        if is_binary(category) do
          %{name: category}
        else
          category
        end
      end)

    notebook_params =
      notebook_params
      |> Map.put("categories", categories)

    form =
      socket.assigns.form
      |> AshPhoenix.Form.validate(notebook_params)
      |> AshPhoenix.Form.update_options(fn options ->
        Keyword.put(options, :selected_categories, socket.assigns.selected_categories)
      end)

    {:noreply,
     socket
     |> assign(form: form)
     |> assign(:continue_notice, "Your changes were auromatically recovered")}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :notebook_picture, ref)}
  end

  @impl true
  def handle_event("toggle_category", %{"name" => category_name}, socket) do
    selected_categories =
      if category_name in socket.assigns.selected_categories do
        List.delete(socket.assigns.selected_categories, category_name)
      else
        [category_name | socket.assigns.selected_categories]
      end

    form =
      AshPhoenix.Form.update_options(socket.assigns.form, fn options ->
        Keyword.put(options, :selected_categories, selected_categories)
      end)

    {:noreply, assign(socket, selected_categories: selected_categories, form: form)}
  end

  @impl true
  def handle_event("save", %{"notebook" => params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :notebook_picture, fn %{key: key}, _entry ->
        {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{key}"}
      end)

    notebook_params =
      params
      |> Map.put("categories", Enum.map(socket.assigns.selected_categories, &%{"name" => &1}))
      |> Map.put("pictures", Enum.map(uploaded_files, &%{"url" => &1}))

    case AshPhoenix.Form.submit(socket.assigns.form, params: notebook_params) do
      {:ok, notebook} ->
        livemd_url = generate_and_upload_livemd(notebook)

        _updated_notebook =
          Amboseli.Blog.Notebook.update!(notebook, %{livemd_url: livemd_url},
            actor: socket.assigns.current_user
          )

        notify_parent({:saved, notebook})

        socket =
          socket
          |> put_flash(
            :info,
            "Notebook #{if socket.assigns.notebook, do: "updated", else: "created"} successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{notebook: notebook}} = socket) do
    form =
      if notebook do
        AshPhoenix.Form.for_update(notebook, :update,
          as: "notebook",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Amboseli.Blog.Notebook, :create,
          as: "notebook",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp presign_picture_upload(entry, socket) do
    filename = "#{entry.client_name}"
    key = "public/notebook_pictures/#{Nanoid.generate()}-#{filename}"

    config = %{
      region: "auto",
      access_key_id: System.get_env("CLOUDFLARE_R2_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("CLOUDFLARE_R2_SECRET_ACCESS_KEY"),
      url:
        "https://#{System.get_env("CLOUDFLARE_BUCKET_NAME")}.#{System.get_env("CLOUDFLARE_ACCOUNT_ID")}.r2.cloudflarestorage.com"
    }

    IO.inspect(entry.client_type, label: "client_type")

    {:ok, presigned_url} =
      Amboseli.S3Upload.presigned_put(config,
        key: key,
        content_type: entry.client_type,
        max_file_size: socket.assigns.uploads[entry.upload_config].max_file_size
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: presigned_url
    }

    {:ok, meta, socket}
  end

  defp get_selected_categories(nil), do: []
  defp get_selected_categories(%{categories: %Ash.NotLoaded{}}), do: []

  defp get_selected_categories(notebook) do
    notebook.categories
    |> Enum.map(& &1.name)
  end

  defp generate_and_upload_livemd(notebook) do
    livemd_content = generate_livemd_content(notebook)
    filename = "#{notebook.id}.livemd"
    key = "public/notebooks/#{filename}"

    config = %{
      region: "auto",
      access_key_id: System.get_env("CLOUDFLARE_R2_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("CLOUDFLARE_R2_SECRET_ACCESS_KEY"),
      url:
        "https://#{System.get_env("CLOUDFLARE_BUCKET_NAME")}.#{System.get_env("CLOUDFLARE_ACCOUNT_ID")}.r2.cloudflarestorage.com"
    }

    {:ok, presigned_url} =
      Amboseli.S3Upload.presigned_put(config,
        key: key,
        content_type: "text/markdown",
        max_file_size: 10_000_000
      )

    HTTPoison.put(presigned_url, livemd_content, [{"Content-Type", "text/markdown"}])

    "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{key}"
  end

  def generate_livemd_content(notebook) do
    """
    # #{notebook.title}

    #{notebook.body}

    ## Categories
    #{Enum.map_join(notebook.categories, ", ", & &1.name)}

    ## Pictures
    #{Enum.map_join(notebook.pictures, "\n", fn picture -> "![](#{picture.url})" end)}
    """
  end
end
