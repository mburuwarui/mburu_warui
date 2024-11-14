defmodule Amboseli.Blog.Bookmark do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Blog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "bookmark"
  end

  graphql do
    type :bookmark
  end

  postgres do
    table "bookmarks"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end

      reference :post do
        on_delete :delete
      end

      reference :comment do
        on_delete :delete
      end
    end
  end

  resource do
    description "A bookmark of a post by a user"
  end

  code_interface do
    define :bookmark_post, args: [:post_id]
  end

  actions do
    defaults [:read, :destroy]

    create :bookmark_post do
      upsert? true
      upsert_identity :unique_user_and_post

      argument :post_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:post_id, arg(:post_id))
      change relate_actor(:user)
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type([:destroy]) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  pub_sub do
    module AmboseliWeb.Endpoint
    prefix "bookmark"

    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
      allow_nil? false
    end

    belongs_to :post, Amboseli.Blog.Post do
      public? true
      allow_nil? false
    end

    belongs_to :comment, Amboseli.Blog.Comment do
      public? true
      allow_nil? true
    end
  end

  identities do
    identity :unique_user_and_post, [:user_id, :post_id]
  end
end
