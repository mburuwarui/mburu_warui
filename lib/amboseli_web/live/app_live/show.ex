defmodule AmboseliWeb.AppLive.Show do
  use AmboseliWeb, :blog_view

  @impl true
  def render(assigns) do
    ~H"""
    <section class="container px-6 py-8 mx-auto lg:py-16 max-w-3xl">
      <.header>
        App <%= @app.id %>
        <:subtitle>This is a app record from your database.</:subtitle>

        <:actions>
          <.link patch={~p"/apps/#{@app}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit app</.button>
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Id"><%= @app.id %></:item>

        <:item title="Title"><%= @app.title %></:item>

        <:item title="Description"><%= @app.description %></:item>

        <:item title="Picture"><%= @app.picture %></:item>

        <:item title="Visibility"><%= @app.visibility %></:item>

        <:item title="User"><%= @app.user_id %></:item>
      </.list>

      <.back navigate={~p"/apps"}>Back to apps</.back>
    </section>

    <.modal :if={@live_action == :edit} id="app-modal" show on_cancel={JS.patch(~p"/apps/#{@app}")}>
      <.live_component
        module={AmboseliWeb.AppLive.FormComponent}
        id={@app.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        app={@app}
        patch={~p"/apps/#{@app}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:app, Ash.get!(Amboseli.Catalog.App, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"
end
