defmodule Domovik.Helpers do
  @moduledoc """
  This module contains helpers function available in the HTML.ex templates
  """
  def active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])
    if path == current_path do
      "active"
    else
      ""
    end
  end
end
