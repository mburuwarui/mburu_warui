defmodule Amboseli.Repo.Migrations.ProductUpgradeWithPubsubAndPolicies do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:products, "products_user_id_fkey")

    alter table(:products) do
      add :price, :bigint, null: false
      add :visibility, :text, default: "public"

      modify :user_id,
             references(:users,
               column: :id,
               name: "products_user_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end
  end

  def down do
    drop constraint(:products, "products_user_id_fkey")

    alter table(:products) do
      modify :user_id,
             references(:users,
               column: :id,
               name: "products_user_id_fkey",
               type: :uuid,
               prefix: "public"
             )

      remove :visibility
      remove :price
    end
  end
end
