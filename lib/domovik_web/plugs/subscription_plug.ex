defmodule DomovikWeb.SubscribedPlug do
  require Logger
  @moduledoc """
  This Plug ensures that the user has an active subscription
  """
  @behaviour Plug

  @free_instance Application.compile_env(:domovik, :free_instance) || false



  def init(_params) do
  end

  def call(conn, _params) do
    if @free_instance do
      conn
    else
      user = Pow.Plug.current_user(conn)
      if Domovik.Users.can_access?(user) do
        conn
      else
        conn
        |> Plug.Conn.send_resp(:payment_required, "subscription inactive")
        |> Plug.Conn.halt
      end
    end
  end
end
