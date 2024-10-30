defmodule Amboseli.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Amboseli.Accounts.User, _opts) do
    Application.fetch_env(:amboseli, :token_signing_secret)
  end
end
