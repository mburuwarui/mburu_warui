defmodule AmboseliWeb.ProfileLive.Show do
  use AmboseliWeb, :live_view

  on_mount {AmboseliWeb.LiveUserAuth, :live_user_required}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Profile <%= @profile.id %>
      <:subtitle>This is a profile record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/profile/#{@profile}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit profile</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @profile.id %></:item>

      <:item title="First Name"><%= @profile.first_name %></:item>

      <:item title="Last Name"><%= @profile.last_name %></:item>

      <:item title="Occupation"><%= @profile.occupation %></:item>

      <:item title="Avatar">
        <img src={@profile.avatar} class="rounded-md" />
      </:item>

      <:item title="User"><%= @profile.user_id %></:item>
    </.list>

    <.back navigate={~p"/profile"}>Back to settings</.back>

    <.modal
      :if={@live_action == :edit}
      id="post-modal"
      show
      on_cancel={JS.patch(~p"/profile/#{@profile}")}
    >
      <.live_component
        module={AmboseliWeb.PostLive.FormComponent}
        id={@profile.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        profile={@profile}
        patch={~p"/profile/#{@profile}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Profile")
    |> assign(
      :profile,
      Ash.get!(Amboseli.Accounts.Profile, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    profile = Ash.get!(Amboseli.Accounts.Profile, id, actor: socket.assigns.current_user)

    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, profile)
  end

  @impl true
  def handle_info({AmboseliWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profile, profile)}
  end
end
