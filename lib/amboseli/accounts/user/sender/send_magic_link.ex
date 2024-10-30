defmodule Amboseli.Accounts.User.Senders.SendMagicLink do
  @moduledoc """
  Sends a magic link
  """
  use AshAuthentication.Sender
  use AmboseliWeb, :verified_routes

  @impl AshAuthentication.Sender
  def send(user_or_email, token, _) do
    # will be a user if the token relates to an existing user
    # will be an email if there is no matching user (such as during sign up)
    Amboseli.Accounts.Emails.deliver_magic_link(
      user_or_email,
      url(~p"/auth/user/magic_link/?token=#{token}")
    )
  end
end
