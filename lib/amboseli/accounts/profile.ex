defmodule Amboseli.Accounts.Profile do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "profile"

    routes do
      base "/profiles"

      get :read
      post :create
    end
  end

  graphql do
    type :profile

    queries do
      get :get_profile, :read
    end
  end

  postgres do
    table "profiles"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A profile of a user"
  end

  code_interface do
    define :create
    define :read
    define :list_all
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [:first_name, :last_name, :occupation]

      argument :profile_picture, :string do
        allow_nil? false
      end

      change relate_actor(:user)
      change set_attribute(:avatar, arg(:profile_picture))
    end

    update :update do
      primary? true

      accept [:first_name, :last_name, :occupation]

      argument :profile_picture, :string

      change set_attribute(:avatar, arg(:profile_picture))
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
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
    end

    policy action_type(:update) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
    end

    policy action_type(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
    end
  end

  pub_sub do
    module AmboseliWeb.Endpoint
    prefix "profile"
    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string do
      allow_nil? false
      public? true
      description "The first name of the user"
    end

    attribute :last_name, :string do
      allow_nil? false
      public? true
      description "The last name of the user"
    end

    attribute :occupation, :string do
      allow_nil? false
      public? true
      description "The occupation of the user"
    end

    attribute :avatar, :string do
      public? true
      description "The avatar of the user"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
      allow_nil? false
    end
  end
end
