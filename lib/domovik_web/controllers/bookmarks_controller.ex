defmodule DomovikWeb.BookmarksController do
  use DomovikWeb, :controller

  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Bookmarks

  import Pow.Plug

  def index(conn, params) do
    user = current_user(conn)
    [current_browsers, bookmarks] =
      case params["bs"] do
        nil ->
          [[], Sync.list_bookmarks(user) |> Repo.preload([:browser])]
        _ ->
          browsers = Sync.user_browsers(user, params["bs"])
          [
            Enum.map(browsers, fn b -> b.uuid end),
            Bookmarks.bookmarks_for_browsers(user, Enum.map(browsers, fn b -> b.id end)) |> Repo.preload(:browser)
          ]
      end

    render conn,
      "index.html",
      browsers: Sync.list_user_browsers(user),
      current_browsers: current_browsers,
      bookmarks: bookmarks
  end
end
