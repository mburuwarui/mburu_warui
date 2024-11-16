defmodule Amboseli.Repo.Migrations.AddAppResource do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:apps, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :title, :text, null: false
      add :description, :text, null: false
      add :picture, :text, null: false
      add :visibility, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "apps_user_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end
  end

  def down do
    drop constraint(:apps, "apps_user_id_fkey")

    drop table(:apps)
  end
end