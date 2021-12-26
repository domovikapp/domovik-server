defmodule Domovik.Bookmarks do
  @moduledoc """
  This module contains all the structures and functions linked to the handling
  of bookmarks and tags
  """

  import Ecto.Query
  alias Domovik.Repo

  alias Domovik.Bookmarks.Bookmark

  def create_bookmark(user, browser, bookmark) do
    %Bookmark{}
    |> Bookmark.changeset(user, browser, bookmark)
    |> Repo.insert()
  end

  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  def user_bookmarks(user) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id)
  end

  def other_browsers_bookmarks(user, browser) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id and b.browser_id != ^browser.id)
  end

  # Get a bookmark and ensure that the bookmark actually belong to the user
  def get_bookmark!(user, id), do: Repo.get_by!(Bookmark, user_id: user.id, id: id)

  def bookmarks_for_browsers(user, uuids) do
    Repo.all(
      from b in Bookmark,
        where: b.user_id == ^user.id and b.browser_id in ^uuids,
        order_by: :title
    )
  end
end
