defmodule Amboseli.Repo.Migrations.AddCategoryToApp do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:app_categories, primary_key: false) do
      add :app_id,
          references(:apps,
            column: :id,
            name: "app_categories_app_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          primary_key: true,
          null: false

      add :category_id,
          references(:categories,
            column: :id,
            name: "app_categories_category_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          primary_key: true,
          null: false
    end

    create unique_index(:app_categories, [:app_id, :category_id],
             name: "app_categories_unique_app_category_index"
           )
  end

  def down do
    drop_if_exists unique_index(:app_categories, [:app_id, :category_id],
                     name: "app_categories_unique_app_category_index"
                   )

    drop constraint(:app_categories, "app_categories_app_id_fkey")

    drop constraint(:app_categories, "app_categories_category_id_fkey")

    drop table(:app_categories)
  end
end
