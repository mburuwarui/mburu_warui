defmodule Amboseli.Catalog.Category do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Catalog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "catalog_category"

    routes do
      base "/catalog_categories"

      get :read
      post :create
    end
  end

  graphql do
    type :catalog_category

    queries do
      get :get_category, :read
    end
  end

  postgres do
    table "catalog_categories"
    repo Amboseli.Repo
  end

  resource do
    description "A category of an app"
  end

  code_interface do
    define :create
    define :list_all
  end

  actions do
    defaults [:read, :destroy, :update]

    create :create do
      primary? true

      upsert? true
      upsert_identity :unique_name

      accept [:name, :description]
    end

    read :list_all do
      prepare build(sort: [inserted_at: :desc])
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end
  end

  pub_sub do
    module AmboseliWeb.Endpoint
    prefix "categories"
    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
      description "The category of the blog app"
    end

    attribute :description, :string do
      allow_nil? false
      public? true
      description "The description of the category"
    end

    timestamps()
  end

  relationships do
    many_to_many :apps, Amboseli.Catalog.App do
      through Amboseli.Catalog.AppCategory
      source_attribute_on_join_resource :category_id
      destination_attribute_on_join_resource :app_id
      public? true
    end
  end

  identities do
    identity :unique_name, [:name]
  end
end
