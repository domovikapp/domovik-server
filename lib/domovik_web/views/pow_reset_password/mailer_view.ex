defmodule DomovikWeb.PowResetPassword.MailerView do
  use DomovikWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset your Domovik password"
end
