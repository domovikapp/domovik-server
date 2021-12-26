defmodule DomovikWeb.Api.V1.BookmarksView do
  use DomovikWeb, :view
  alias DomovikWeb.Api.V1.BookmarksView

  def render("index.json", %{bookmarks: bookmarks}) do
    %{data: render_many(bookmarks, BookmarksView, "show.json", as: :bookmark)}
  end

  def render("show.json", %{bookmark: bookmark}) do
    %{data: render_one(bookmark, BookmarksView, "bookmark.json", as: :bookmark)}
  end

  def render("bookmark.json", %{bookmark: bookmark}) do
    %{id: bookmark.id, url: bookmark.url, title: bookmark.title}
  end
end
