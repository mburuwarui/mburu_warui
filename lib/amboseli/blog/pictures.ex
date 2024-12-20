defmodule Amboseli.Blog.Pictures do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Blog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "picture"
  end

  graphql do
    type :picture

    queries do
      get :get_picture, :read
    end
  end

  postgres do
    table "pictures"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end

      reference :notebook do
        on_delete :delete
      end
    end
  end

  resource do
    description "A picture on a blog notebook"
  end

  code_interface do
    define :list_pictures
    define :new_picture, args: [:notebook_id, :url]
  end

  actions do
    defaults [:read, :destroy, :update]

    create :new_picture do
      primary? true

      accept [:url, :notebook_id]

      change set_attribute(:notebook_id, arg(:notebook_id))
      change relate_actor(:user)
    end

    read :list_pictures do
      prepare build(
                sort: [inserted_at: :desc],
                filter: expr(is_approved == true)
              )
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action(:approve) do
      authorize_if actor_attribute_equals(:role, :moderator)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string do
      allow_nil? false
      public? true
      description "The picture of the blog notebook"
    end

    attribute :is_approved, :boolean do
      default true
      public? true
      description "Whether the picture has been approved by a moderator"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
      allow_nil? false
    end

    belongs_to :notebook, Amboseli.Blog.Notebook do
      public? true
      allow_nil? false
    end
  end

  pub_sub do
    module AmboseliWeb.Endpoint
    prefix "add_picture"

    publish_all :create, ["pictures"]
    publish_all :destroy, ["pictures"]
  end
end
