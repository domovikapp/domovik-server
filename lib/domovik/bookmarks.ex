defmodule Domovik.Bookmarks do
  @moduledoc """
  This module contains all the structures and functions linked to the handling
  of bookmarks and tags
  """

  import Ecto.Query
  alias Domovik.Repo

  alias Domovik.Bookmarks.Bookmark

  def user_bookmarks(user) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id)
  end

  def other_browsers_bookmarks(user, browser) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id and b.browser_id != ^browser.id)
  end

  def user_bookmark(user, id), do: Repo.get_by(Bookmark, [user_id: user.id, id: id])

  def bookmarks_for_browsers(user, uuids) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id and b.browser_id in ^uuids, order_by: :title)
  end

  def create_bookmark(user, bookmark, tags) do
    %Bookmark{}
    |> Bookmark.changeset(user, bookmark, tags)
    |> Repo.insert
  end
end
