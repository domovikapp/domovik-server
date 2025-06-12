defmodule DomovikWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use DomovikWeb, :controller
      use DomovikWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: DomovikWeb

      import Plug.Conn
      import DomovikWeb.Gettext
      alias DomovikWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/domovik_web/templates",
        namespace: DomovikWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import DomovikWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers
      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import DomovikWeb.ErrorHelpers
      import DomovikWeb.Gettext
      alias DomovikWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def mailer_view do
    quote do
      use Phoenix.View,
        root: "lib/domovik_web/templates",
        namespace: DomovikWeb

      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers
    end
  end
end
