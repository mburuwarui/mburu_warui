defmodule AmboseliWeb.Router do
  use AmboseliWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :graphql do
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AmboseliWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
    plug AmboseliWeb.ReturnToPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", AmboseliWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes,
      on_mount: [
        {AmboseliWeb.SaveRequestUri, :save_request_uri}
      ] do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {AmboseliWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {AmboseliWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {AmboseliWeb.LiveUserAuth, :live_no_user}
      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.Index, :new
      live "/products/:id/edit", ProductLive.Index, :edit

      live "/products/:id", ProductLive.Show, :show
      live "/products/:id/show/edit", ProductLive.Show, :edit

      live "/posts", PostLive.Index, :index
      live "/posts/:id", PostLive.Show, :show
      live "/posts/new", PostLive.Index, :new
      live "/posts/:id/edit", PostLive.Index, :edit
      live "/posts/:id/show/edit", PostLive.Show, :edit

      live "/posts/category/:category", PostLive.Index, :filter_by_category
      live "/search", PostLive.Index, :search

      live "/posts/:id/comments/new", PostLive.Show, :new_comment
      live "/posts/:id/comments/:c_id/new", PostLive.Show, :new_comment_child
      live "/posts/:id/comments/:c_id/edit", PostLive.Show, :edit_comment

      live "/profile", ProfileLive.Index, :index
      live "/profile/new", ProfileLive.Index, :new
      live "/profile/:id", ProfileLive.Show, :show
      live "/profile/:id/edit", ProfileLive.Index, :edit
      live "/profile/:id/show/edit", ProfileLive.Show, :edit
    end
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui",
            OpenApiSpex.Plug.SwaggerUI,
            path: "/api/json/open_api",
            default_model_expand_depth: 4

    forward "/", AmboseliWeb.AshJsonApiRouter
  end

  scope "/gql" do
    pipe_through [:graphql]

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: Module.concat(["AmboseliWeb.GraphqlSchema"]),
            interface: :playground

    forward "/",
            Absinthe.Plug,
            schema: Module.concat(["AmboseliWeb.GraphqlSchema"])
  end

  scope "/", AmboseliWeb do
    pipe_through :browser

    get "/", PageController, :home

    auth_routes AuthController, Amboseli.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{AmboseliWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    AmboseliWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth"
  end

  # Other scopes may use custom stacks.
  # scope "/api", AmboseliWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:amboseli, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AmboseliWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
