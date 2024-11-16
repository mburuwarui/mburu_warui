defmodule Amboseli.Catalog.AppCategory do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "app_category"

    routes do
      base "/app_categories"

      get :read
    end

    primary_key do
      keys [:app_id, :category_id]
    end
  end

  graphql do
    type :app_category
  end

  postgres do
    table "app_categories"
    repo Amboseli.Repo

    references do
      reference :app do
        on_delete :delete
      end

      reference :category do
        on_delete :delete
      end
    end
  end

  resource do
    description "A join table for category of an app"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_app_category
    end
  end

  relationships do
    belongs_to :app, Amboseli.Catalog.App do
      public? true
      primary_key? true
      allow_nil? false
    end

    belongs_to :category, Amboseli.Catalog.Category do
      public? true
      primary_key? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_app_category, [:app_id, :category_id]
  end
end
