defmodule Amboseli.Catalog.Product do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Catalog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "product"
  end

  graphql do
    type :product
  end

  postgres do
    table "products"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A catalog product with extended features and policies"
  end

  code_interface do
    define :create
    define :read
    define :update
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:title, :description, :price, :visibility]

      validate string_length(:title, min: 3, max: 255)
      validate string_length(:description, min: 3, max: 255)
      validate numericality(:price, greater_than: 0)

      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:title, :description, :price, :visibility]

      validate string_length(:title, min: 3, max: 255)
      validate string_length(:description, min: 3, max: 255)
      validate numericality(:price, greater_than: 0)
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(visibility == :public)
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
      authorize_if actor_attribute_equals(:role, :user)
    end

    policy action_type(:update) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
      authorize_if actor_present()
    end

    policy action_type(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
    end

    policy action_type(:create) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
    end
  end

  pub_sub do
    module AmboseliWeb.Endpoint
    prefix "products"
    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  attributes do
    uuid_primary_key :id

    attribute :description, :string do
      allow_nil? false
      public? true
      description "The description of the product"
    end

    attribute :title, :string do
      allow_nil? false
      public? true
      description "The title of the product"
    end

    attribute :price, :integer do
      allow_nil? false
      public? true
      description "The price of the product"
    end

    attribute :visibility, :atom do
      constraints one_of: [:public, :private]
      default :public
      public? true
      description "Visibility setting for the product"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
    end
  end
end
