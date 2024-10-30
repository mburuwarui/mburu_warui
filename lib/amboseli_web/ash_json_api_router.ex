defmodule AmboseliWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Amboseli.Catalog"])],
    open_api: "/open_api"
end
