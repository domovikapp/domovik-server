defmodule DomovikWeb.Pow.Mailer do
  @moduledoc """
  This module handle emails management concerning POW.
  """
  use Pow.Phoenix.Mailer
  use Bamboo.Mailer, otp_app: :domovik
  require Logger

  import Bamboo.Email

  @impl true
  def cast(%{user: user, subject: subject, text: text, html: html, assigns: _assigns}) do
    new_email(
      to: user.email,
      from: "no-reply@domovik.app",
      subject: subject,
      html_body: html,
      text_body: text
    )
  end

  @impl true
  def process(email) do
    case deliver_later(email) do
      {:ok, _} -> Logger.debug("E-mail sent: #{inspect email}")
      {:error, e} -> Logger.error("Error while sending an email: #{e}")
    end
  end
end
