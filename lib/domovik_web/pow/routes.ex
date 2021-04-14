defmodule DomovikWeb.Pow.Routes do
  @moduledoc """
  This module contains our override for the default POW routes.
  """
  use Pow.Phoenix.Routes
  alias DomovikWeb.Router.Helpers, as: Routes

  @doc """
  We want to redirect the user to the browsers page after they logged in
  """
  @impl true
  def after_sign_in_path(conn), do: Routes.browser_path(conn, :index)
end
