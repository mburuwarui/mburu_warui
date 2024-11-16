defmodule Amboseli.Repo.Migrations.AddLinkToAppResource do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:apps) do
      add :link, :text, null: false
    end
  end

  def down do
    alter table(:apps) do
      remove :link
    end
  end
end