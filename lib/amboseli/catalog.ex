defmodule Amboseli.Catalog do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Amboseli.Catalog.Product
    resource Amboseli.Catalog.App
    resource Amboseli.Catalog.Category
    resource Amboseli.Catalog.AppCategory
  end
end
