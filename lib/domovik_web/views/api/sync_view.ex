defmodule DomovikWeb.Api.V1.BrowserView do
  use DomovikWeb, :view
  alias DomovikWeb.Api.V1.{BrowserView, TabView, CommandView}

  def render("index.json", %{browsers: browsers}) do
    %{data: render_many(browsers, BrowserView, "browser.json")}
  end

  def render("show.json", %{browser: browser}) do
    %{data: render_one(browser, BrowserView, "browser.json")}
  end

  def render("browser.json", %{browser: browser}) do
    if Ecto.assoc_loaded?(browser.tabs) do
      %{
        name: browser.name,
        uuid: browser.uuid,
        last_update: browser.last_update,
        tabs: render_many(browser.tabs, TabView, "show.json")
      }
    else
      %{name: browser.name, uuid: browser.uuid, last_update: browser.last_update}
    end
  end

  def render("pending.json", %{browser: browser}) do
    %{data: render_many(browser.pending_commands, CommandView, "show.json")}
  end
end

defmodule DomovikWeb.Api.V1.TabView do
  use DomovikWeb, :view

  def render("show.json", %{tab: tab}) do
    %{
      url: tab.url,
      title: tab.title,
      favicon: tab.favicon,
      active: tab.active,
      pinned: tab.pinned,
      window: tab.window,
      index: tab.index
    }
  end
end

defmodule DomovikWeb.Api.V1.CommandView do
  use DomovikWeb, :view

  def render("show.json", %{command: command}) do
    command.payload
  end
end
