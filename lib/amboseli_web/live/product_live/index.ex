defmodule AmboseliWeb.ProductLive.Index do
  use AmboseliWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <.header>
        Listing Products
        <:actions>
          <.link patch={~p"/products/new"}>
            <.button>New Product</.button>
          </.link>
        </:actions>
      </.header>

      <.table
        id="products"
        rows={@streams.products}
        row_click={fn {_id, product} -> JS.navigate(~p"/products/#{product}") end}
      >
        <:col :let={{_id, product}} label="Title"><%= product.title %></:col>

        <:col :let={{_id, product}} label="Description"><%= product.description %></:col>

        <:col :let={{_id, product}} label="Price"><%= product.price %></:col>

        <:col :let={{_id, product}} label="Visibility"><%= product.visibility %></:col>

        <:col :let={{_id, product}} label="User"><%= product.user_email %></:col>

        <:action :let={{_id, product}}>
          <div class="sr-only">
            <.link navigate={~p"/products/#{product}"}>Show</.link>
          </div>

          <.link patch={~p"/products/#{product}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, product}}>
          <.link
            phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/products")}
    >
      <.live_component
        module={AmboseliWeb.ProductLive.FormComponent}
        id={(@product && @product.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        product={@product}
        patch={~p"/products"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Amboseli.PubSub, "products:created")
      Phoenix.PubSub.subscribe(Amboseli.PubSub, "products:updated")
      Phoenix.PubSub.subscribe(Amboseli.PubSub, "products:deleted")
    end

    {:ok,
     socket
     |> stream(:products, [])
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(
      :product,
      Ash.get!(Amboseli.Catalog.Product, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, nil)
  end

  defp apply_action(socket, :index, _params) do
    products =
      Amboseli.Catalog.Product.list_public!(
        actor: socket.assigns[:current_user],
        load: [:user_email]
      )

    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
    |> stream(:products, products)
  end

  @impl true
  def handle_info({AmboseliWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product |> Ash.load!(:user_email), at: 0)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "products:created", payload: payload},
        socket
      ) do
    {:noreply, stream_insert(socket, :products, payload.data |> Ash.load!(:user_email), at: 0)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "products:updated", payload: payload},
        socket
      ) do
    case payload.data.visibility do
      :public ->
        {:noreply,
         stream_insert(socket, :products, payload.data |> Ash.load!(:user_email), at: 0)}

      :private ->
        {:noreply, stream_delete(socket, :products, payload.data)}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "products:deleted", payload: payload},
        socket
      ) do
    {:noreply, stream_delete(socket, :products, payload.data)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Ash.get!(Amboseli.Catalog.Product, id, actor: socket.assigns.current_user)
    Ash.destroy!(product, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
