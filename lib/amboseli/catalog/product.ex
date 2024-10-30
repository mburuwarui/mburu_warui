defmodule Amboseli.Catalog.Product do
  use Ash.Resource,
    otp_app: :amboseli,
    domain: Amboseli.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "product"
  end

  graphql do
    type :product
  end

  postgres do
    table "products"
    repo Amboseli.Repo
  end

  actions do
    defaults [:read, :destroy, create: [:description, :title], update: [:description, :title]]
  end

  attributes do
    uuid_primary_key :id

    attribute :description, :string do
      allow_nil? false
      public? true
    end

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Amboseli.Accounts.User do
      public? true
    end
  end
end
