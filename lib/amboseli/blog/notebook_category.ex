defmodule Amboseli.Blog.NotebookCategory do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "notebook_category"

    routes do
      base "/notebook_categories"

      get :read
    end

    primary_key do
      keys [:notebook_id, :category_id]
    end
  end

  graphql do
    type :notebook_category
  end

  postgres do
    table "notebook_categories"
    repo Amboseli.Repo

    references do
      reference :notebook do
        on_delete :delete
      end

      reference :category do
        on_delete :delete
      end
    end
  end

  resource do
    description "A join table for category of a notebook"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_notebook_category
    end
  end

  relationships do
    belongs_to :notebook, Amboseli.Blog.Notebook do
      public? true
      primary_key? true
      allow_nil? false
    end

    belongs_to :category, Amboseli.Blog.Category do
      public? true
      primary_key? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_notebook_category, [:notebook_id, :category_id]
  end
end
