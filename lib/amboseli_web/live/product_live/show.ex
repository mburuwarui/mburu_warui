defmodule AmboseliWeb.ProductLive.Show do
  use AmboseliWeb, :live_view

  import SaladUI.Button

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Product <%= @product.id %>
      <:subtitle>This is a product record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/products/#{@product}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit product</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Title"><%= @product.title %></:item>

      <:item title="Description"><%= @product.description %></:item>

      <:item title="Price"><%= @product.price %></:item>

      <:item title="Visibility"><%= @product.visibility %></:item>

      <:item title="User"><%= @product.user_email %></:item>
    </.list>

    <.back navigate={~p"/products"}>Back to products</.back>

    <.modal
      :if={@live_action == :edit}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/products/#{@product}")}
    >
      <.live_component
        module={AmboseliWeb.ProductLive.FormComponent}
        id={@product.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        product={@product}
        patch={~p"/products/#{@product}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Amboseli.PubSub, "products:updated")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :product,
       Ash.get!(Amboseli.Catalog.Product, id,
         actor: socket.assigns.current_user,
         load: [:user_email]
       )
     )}
  end

  @impl true
  def handle_info({AmboseliWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, assign(socket, :product, product |> Ash.load!(:user_email))}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "products:updated", payload: payload},
        socket
      ) do
    {:noreply, assign(socket, :product, payload.data |> Ash.load!(:user_email))}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
