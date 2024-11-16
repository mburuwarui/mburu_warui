defmodule AmboseliWeb.AppLive.FormComponent do
  use AmboseliWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage app records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="app-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:picture]} type="text" label="Picture" />
        <.input field={@form[:link]} type="text" label="Link" />
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
                checked={category.name in @selected_categories}
                label={category.name}
                phx-click="toggle_category"
                phx-value-name={category.name}
                phx-target={@myself}
              />
            </div>
          <% end %>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save App</.button>
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
     |> assign(:available_categories, Amboseli.Catalog.Category.list_all!())
     |> assign(:selected_categories, get_selected_categories(assigns.app))
     |> assign_form()}
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
  def handle_event("validate", %{"app" => app_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, app_params))}
  end

  def handle_event("save", %{"app" => params}, socket) do
    app_params =
      params
      |> Map.put("categories", Enum.map(socket.assigns.selected_categories, &%{"name" => &1}))

    case AshPhoenix.Form.submit(socket.assigns.form, params: app_params) do
      {:ok, app} ->
        notify_parent({:saved, app})

        socket =
          socket
          |> put_flash(:info, "App #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{app: app}} = socket) do
    form =
      if app do
        AshPhoenix.Form.for_update(app, :update, as: "app", actor: socket.assigns.current_user)
      else
        AshPhoenix.Form.for_create(Amboseli.Catalog.App, :create,
          as: "app",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp get_selected_categories(nil), do: []
  defp get_selected_categories(%{categories: %Ash.NotLoaded{}}), do: []

  defp get_selected_categories(notebook) do
    notebook.categories
    |> Enum.map(& &1.name)
  end
end
