defmodule Amboseli.Accounts.User.Senders.SendNewUserConfirmationEmail do
  @moduledoc """
  Sends an email confirmation email
  """
  use AshAuthentication.Sender
  use AmboseliWeb, :verified_routes

  @impl AshAuthentication.Sender
  def send(user, token, _opts) do
    Amboseli.Accounts.Emails.deliver_email_confirmation_instructions(
      user,
      url(~p"/auth/user/confirm_new_user?#{[confirm: token]}")
    )
  end
end
