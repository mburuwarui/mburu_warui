defmodule Amboseli.Accounts do
  use Ash.Domain

  resources do
    resource Amboseli.Accounts.Token
    resource Amboseli.Accounts.User
  end
end
