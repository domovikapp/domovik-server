defmodule DomovikWeb.StripeWebhooksPlug do
  @moduledoc """
  This plug decyphers callbacks from Stripe before forwarding them to
  the controller per se.
  """
  require Logger
  @behaviour Plug

  def init(config), do: config

  def call(%{request_path: "/stripe/hooks"} = conn, _) do
    signing_secret = Application.get_env(:stripity_stripe, :signing_secret)
    [stripe_signature] = Plug.Conn.get_req_header(conn, "stripe-signature")

    with {:ok, body, _} <- Plug.Conn.read_body(conn),
         {:ok, stripe_event} <-
           Stripe.Webhook.construct_event(body, stripe_signature, signing_secret) do
      Plug.Conn.assign(conn, :stripe_event, stripe_event)
    else
      {:error, error} ->
        Logger.error("while processing Stripe hook: #{inspect(conn)}")

        conn
        |> Plug.Conn.send_resp(:bad_request, error.message)
        |> Plug.Conn.halt()
    end
  end

  def call(conn, _), do: conn
end
