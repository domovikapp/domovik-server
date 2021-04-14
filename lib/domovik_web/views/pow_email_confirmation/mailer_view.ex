defmodule DomovikWeb.PowEmailConfirmation.MailerView do
  use DomovikWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
