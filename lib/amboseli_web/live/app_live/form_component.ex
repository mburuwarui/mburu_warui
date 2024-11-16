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
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"app" => app_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, app_params))}
  end

  def handle_event("save", %{"app" => app_params}, socket) do
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
end
