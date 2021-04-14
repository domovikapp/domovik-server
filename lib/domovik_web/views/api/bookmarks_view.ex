defmodule DomovikWeb.Api.V1.BookmarksView do
  use DomovikWeb, :view
  alias DomovikWeb.Api.V1.BookmarksView

  def render("bookmarks.json", %{bookmarks: bookmarks}) do
    %{data: render_many(bookmarks, BookmarksView, "show.json", as: :bookmark)}
  end

  def render("show.json", %{bookmark: bookmark}) do
    %{url: bookmark.url, title: bookmark.title}
  end
end
