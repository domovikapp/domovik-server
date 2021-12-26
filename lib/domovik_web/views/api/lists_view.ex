defmodule DomovikWeb.Api.V1.ListView do
  use DomovikWeb, :view
  alias DomovikWeb.Api.V1.{ListView, LinkView}

  def render("index.json", %{lists: lists}) do
    %{data: render_many(lists, ListView, "list.json")}
  end

  def render("pretty_index.json", %{lists: lists}) do
    %{data: render_many(lists, ListView, "pretty_list.json")}
  end

  def render("show.json", %{list: list}) do
    %{data: render_one(list, ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    if Ecto.assoc_loaded?(list.links) do
      %{name: list.name, uuid: list.uuid, links: render_many(list.links, LinkView, "link.json")}
    else
      %{name: list.name, uuid: list.uuid}
    end
  end

  def render("pretty_list.json", %{list: list}) do
    if Ecto.assoc_loaded?(list.links) do
      %{name: list.name, links: render_many(list.links, LinkView, "pretty_link.json")}
    else
      %{name: list.name}
    end
  end
end

defmodule DomovikWeb.Api.V1.LinkView do
  use DomovikWeb, :view

  def render("link.json", %{link: link}) do
    %{id: link.id, url: link.url, title: link.title, favicon: link.favicon}
  end

  def render("pretty_link.json", %{link: link}) do
    %{url: link.url, title: link.title}
  end
end
