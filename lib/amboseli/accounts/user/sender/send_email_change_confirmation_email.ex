defmodule Amboseli.Accounts.User.Senders.SendEmailChangeConfirmationEmail do
  @moduledoc """
  Sends an email change confirmation email
  """
  use AshAuthentication.Sender
  use AmboseliWeb, :verified_routes

  @impl AshAuthentication.Sender
  def send(user, token, _opts) do
    Amboseli.Accounts.Emails.deliver_email_change_confirmation_instructions(
      user,
      url(~p"/auth/user/confirm_change?#{[confirm: token]}")
    )
  end
end
