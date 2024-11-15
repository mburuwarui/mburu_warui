defmodule AmboseliWeb.AppLive.Index do
  use AmboseliWeb, :blog_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="m-auto max-w-3xl">
      <.header>
        Listing Apps
        <:actions>
          <.link patch={~p"/apps/new"}>
            <.button>New App</.button>
          </.link>
        </:actions>
      </.header>

      <.table
        id="apps"
        rows={@streams.apps}
        row_click={fn {_id, app} -> JS.navigate(~p"/apps/#{app}") end}
      >
        <:col :let={{_id, app}} label="Id"><%= app.id %></:col>

        <:col :let={{_id, app}} label="Title"><%= app.title %></:col>

        <:col :let={{_id, app}} label="Description"><%= app.description %></:col>

        <:col :let={{_id, app}} label="Picture"><%= app.picture %></:col>

        <:col :let={{_id, app}} label="Visibility"><%= app.visibility %></:col>

        <:col :let={{_id, app}} label="User"><%= app.user_id %></:col>

        <:action :let={{_id, app}}>
          <div class="sr-only">
            <.link navigate={~p"/apps/#{app}"}>Show</.link>
          </div>

          <.link patch={~p"/apps/#{app}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, app}}>
          <.link
            phx-click={JS.push("delete", value: %{id: app.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>

    <.modal :if={@live_action in [:new, :edit]} id="app-modal" show on_cancel={JS.patch(~p"/apps")}>
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
    {:ok,
     socket
     |> stream(:apps, Ash.read!(Amboseli.Catalog.App, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit App")
    |> assign(:app, Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New App")
    |> assign(:app, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Apps")
    |> assign(:app, nil)
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
end
