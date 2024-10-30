defmodule Amboseli.Catalog do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Amboseli.Catalog.Product
  end
end
