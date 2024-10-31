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
    {:ok,
     socket
     |> stream(
       :products,
       Ash.read!(Amboseli.Catalog.Product, actor: socket.assigns[:current_user])
     )
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
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({AmboseliWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Ash.get!(Amboseli.Catalog.Product, id, actor: socket.assigns.current_user)
    Ash.destroy!(product, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :products, product)}
  end
end