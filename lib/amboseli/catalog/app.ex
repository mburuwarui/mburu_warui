defmodule Amboseli.Catalog.App do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Catalog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "app"
  end

  graphql do
    type :app
  end

  postgres do
    table "apps"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A catalog app with extended features and policies"
  end

  code_interface do
    define :create
    define :read
    define :update
    define :list_public
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:title, :description, :picture, :visibility]

      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:title, :description, :picture, :visibility]
    end

    update :public_update do
      accept [:visibility]
    end

    read :list_public do
      prepare build(sort: [updated_at: :desc], filter: expr(visibility == :public))
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
    prefix "apps"
    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  validations do
    validate string_length(:title, min: 3, max: 255)
    validate string_length(:description, min: 3, max: 255)
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
      description "The title of the app"
    end

    attribute :description, :string do
      allow_nil? false
      public? true
      description "The description of the app"
    end

    attribute :picture, :string do
      allow_nil? false
      public? true
      description "The picture of the app"
    end

    attribute :visibility, :atom do
      constraints one_of: [:public, :private]
      public? true
      description "Visibility setting for the app"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
    end
  end

  calculations do
    calculate :user_email, :string, expr(user.email)
  end
end
