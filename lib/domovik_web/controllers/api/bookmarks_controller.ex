defmodule DomovikWeb.Api.V1.BookmarksController do
  use DomovikWeb, :controller

  import Pow.Plug

  alias Domovik.Sync
  alias Domovik.Bookmarks

  action_fallback DomovikWeb.FallbackController

  @doc """
  Returns all the bookmarks of the user making the API call
  """
  def index(conn, _) do
    bookmarks = conn |> current_user |> Bookmarks.user_bookmarks()
    render(conn, "bookmarks.json", bookmarks: bookmarks)
  end

  @doc """
  Returns all the bookmarks of the user making the API call, except
  for those of the browser passed as a parameter.
  """
  def index_others(conn, %{"uuid" => uuid}) do
    browser = Sync.get_user_browser!(uuid, current_user(conn).id)
    user = current_user(conn)
    bookmarks = Bookmarks.other_browsers_bookmarks(user, browser)
    render(conn, "bookmarks.json", bookmarks: bookmarks)
  end

  @doc """
  Creates a new bookmarks for the user making the API call,
  including the mentioned tags if needed
  """
  def create(conn, %{"bookmark" => bookmark, "tags" => tags}) do
    user = current_user(conn)

    case Bookmarks.create_bookmark(user, bookmark, tags) do
      {:ok, _bookmark} ->
        send_resp(conn, :created, "")
      _ ->
        send_resp(conn, :bad_request, "")
    end
  end

  def sync_all(conn, %{"uuid" => uuid, "bookmarks" => bookmarks}) do
    user = current_user(conn)

    case Sync.get_user_browser!(uuid, user.id) do
      browser when not is_nil(browser) ->
        Sync.update_bookmarks(user, browser, bookmarks)
        send_resp(conn, :created, "")

      nil ->
        send_resp(conn, :unauthorized, "")
    end
  end
end
