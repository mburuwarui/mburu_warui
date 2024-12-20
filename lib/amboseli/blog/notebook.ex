defmodule Amboseli.Blog.Notebook do
  require Ecto.Query

  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Blog,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  json_api do
    type "notebook"

    routes do
      base "/notebooks"

      get :read
      post :create
    end
  end

  graphql do
    type :notebook

    queries do
      get :get_notebook, :read
    end
  end

  postgres do
    table "notebooks"
    repo Amboseli.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A blog notebook with extended features and policies"
  end

  code_interface do
    define :create
    define :read
    define :update
    define :like
    define :dislike
    define :unbookmark
    define :bookmark
    define :inc_page_views
    define :list_public
    define :list_dashboard
    define :search_notebooks
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:title, :body, :visibility]

      validate string_length(:title, min: 4)
      validate string_length(:body, min: 100)

      argument :pictures, {:array, :map} do
        allow_nil? false
      end

      argument :categories, {:array, :map} do
        allow_nil? false
      end

      change relate_actor(:user)

      change manage_relationship(:categories,
               type: :append_and_remove,
               on_no_match: :create
             )

      change manage_relationship(:pictures,
               type: :create,
               on_match: :ignore,
               on_no_match: :create
             )
    end

    update :update do
      primary? true
      accept [:title, :body, :visibility, :livemd_url]
      require_atomic? false

      argument :pictures, {:array, :map}

      argument :categories, {:array, :map}

      change manage_relationship(:pictures,
               type: :create,
               on_match: :ignore,
               on_no_match: :create
             )

      change manage_relationship(:categories,
               type: :append_and_remove,
               on_no_match: :create
             )
    end

    update :like do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Amboseli.Blog.Like.like(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :dislike do
      accept []

      manual fn changeset, %{actor: actor} ->
        like =
          Ecto.Query.from(like in Amboseli.Blog.Like,
            where: like.user_id == ^actor.id,
            where: like.notebook_id == ^changeset.data.id
          )

        Amboseli.Repo.delete_all(like)

        {:ok, changeset.data}
      end
    end

    update :bookmark do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Amboseli.Blog.Bookmark.bookmark_notebook(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :unbookmark do
      accept []

      manual fn changeset, %{actor: actor} ->
        bookmark =
          Ecto.Query.from(like in Amboseli.Blog.Bookmark,
            where: like.user_id == ^actor.id,
            where: like.notebook_id == ^changeset.data.id
          )

        Amboseli.Repo.delete_all(bookmark)

        {:ok, changeset.data}
      end
    end

    update :inc_page_views do
      accept []

      change increment(:page_views, amount: 1)
    end

    read :list_public do
      prepare build(
                sort: [inserted_at: :desc],
                filter: expr(visibility == :public)
              )
    end

    read :list_dashboard do
      prepare build(sort: [inserted_at: :desc], filter: [user_id: actor(:id)])
    end

    read :search_notebooks do
      argument :query, :string do
        allow_nil? false
      end

      prepare build(
                filter: [title: arg(:query)],
                sort: [inserted_at: :desc],
                limit: 5
              )
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
    prefix "notebooks"
    publish_all :create, ["created"]
    publish_all :update, ["updated"]
    publish_all :destroy, ["deleted"]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
      description "The title of the blog notebook"
    end

    attribute :body, :string do
      allow_nil? false
      public? true
      description "The main content of the blog notebook"
    end

    attribute :visibility, :atom do
      constraints one_of: [:public, :private, :friends]
      default :public
      public? true
      description "Visibility setting for the notebook"
    end

    attribute :page_views, :integer do
      default 0
      public? true
      description "The number of views for the notebook"
    end

    attribute :livemd_url, :string do
      allow_nil? true
      public? true
      description "The URL of the livemd file"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
      allow_nil? false
    end

    has_many :comments, Amboseli.Blog.Comment
    has_many :likes, Amboseli.Blog.Like
    has_many :bookmarks, Amboseli.Blog.Bookmark
    has_many :pictures, Amboseli.Blog.Pictures

    many_to_many :categories, Amboseli.Blog.Category do
      through Amboseli.Blog.NotebookCategory
      source_attribute_on_join_resource :notebook_id
      destination_attribute_on_join_resource :category_id
      public? true
    end
  end

  calculations do
    calculate :popularity_score,
              :float,
              expr(like_count * 2 + comment_count + bookmark_count + page_views)

    calculate :reading_time, :integer, expr(string_length(body) / 2000)

    calculate :liked_by_user, :boolean, expr(exists(likes, user_id: ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? true
      end
    end

    calculate :bookmarked_by_user, :boolean, expr(exists(bookmarks, user_id: ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? true
      end
    end
  end

  aggregates do
    count :like_count, :likes
    count :comment_count, :comments
    count :bookmark_count, :bookmarks
  end
end
