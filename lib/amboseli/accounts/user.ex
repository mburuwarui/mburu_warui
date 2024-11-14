defmodule Amboseli.Accounts.User do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  authentication do
    tokens do
      enabled? true
      token_resource Amboseli.Accounts.Token
      signing_secret Amboseli.Secrets
    end

    strategies do
      password :password do
        identity_field :email
      end

      magic_link do
        identity_field :email
        registration_enabled? true

        sender(Amboseli.Accounts.User.Senders.SendMagicLink)
      end
    end

    add_ons do
      confirmation :confirm_new_user do
        monitor_fields [:email]
        confirm_on_create? true
        confirm_on_update? false
        sender Amboseli.Accounts.User.Senders.SendNewUserConfirmationEmail
      end
    end
  end

  postgres do
    table "users"
    repo Amboseli.Repo
  end

  actions do
    defaults [:read, :destroy, create: [], update: [:email, :role]]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    # policy always() do
    #   forbid_if always()
    # end

    policy action_type([:create, :update]) do
      authorize_if expr(id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: true, sensitive?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :author, :user]
      default :user
      public? true
      description "The role of the user"
    end

    timestamps()
  end

  relationships do
    has_many :products, Amboseli.Catalog.Product
    has_many :posts, Amboseli.Blog.Post
    has_many :comments, Amboseli.Blog.Comment
    has_many :likes, Amboseli.Blog.Like
    has_many :bookmarks, Amboseli.Blog.Bookmark
    has_one :profile, Amboseli.Accounts.Profile
  end

  identities do
    identity :unique_email, [:email]
  end
end
