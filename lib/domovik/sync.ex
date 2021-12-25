defmodule Domovik.Sync do
  @moduledoc """
  The Sync context.
  """

  import Ecto.Query, warn: false
  alias Domovik.Repo
  alias Ecto.Multi

  alias Domovik.Users.User
  alias Domovik.Sync.{Browser, Tab, Command}
  alias Domovik.Bookmarks.Bookmark

  @doc """
  Returns the list of all the browsers of a given user.
  """
  def list_user_browsers(%User{} = user) do
    Repo.all(from b in Browser, where: b.user_id == ^user.id, order_by: b.inserted_at)
  end

  @doc """
  Returns the list of all the bookmarks of a given user.
  """
  def list_bookmarks(%User{} = user) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user.id, order_by: b.title)
  end

  def user_browsers(user, uuids) do
    Repo.all(from b in Browser, where: b.user_id == ^user.id and b.uuid in ^uuids, order_by: b.inserted_at)
  end

  @doc """
  Gets a single browser, ensuring it belongs to the specified user.

  Return `nil` if the Browser does not exist and raises if more than one entry.
  """
  def get_user_browser!(uuid, user_id), do: Repo.get_by!(Browser, [uuid: uuid, user_id: user_id])

  @doc """
  Creates a browser.

  ## Examples

      iex> create_browser(%{field: value})
      {:ok, %Browser{}}

      iex> create_browser(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_browser(%User{} = user, attrs \\ %{}) do
    %Browser{last_update: 0, uuid: UUID.uuid1(), user_id: user.id}
    |> Browser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a browser.

  ## Examples

  iex> update_browser(browser, %{field: new_value})
  {:ok, %Browser{}}

  iex> update_browser(browser, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_browser(%Browser{} = browser, attrs) do
    browser
    |> Browser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a browser.

  ## Examples

  iex> delete_browser(browser)
  {:ok, %Browser{}}

  iex> delete_browser(browser)
  {:error, %Ecto.Changeset{}}

  """
  def delete_browser(%Browser{} = browser) do
    Repo.delete(browser)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking browser changes.

  ## Examples

  iex> change_browser(browser)
  %Ecto.Changeset{data: %Browser{}}

  """
  def change_browser(%Browser{} = browser, attrs \\ %{}) do
    Browser.changeset(browser, attrs)
  end

  def update_tabs(%Browser{} = browser, tabs, timestamp) do
    m = Multi.new()
    |> Multi.delete_all(:clear_old_tabs, from(t in Tab, where: t.browser_id == ^browser.id))

    Enum.reduce(tabs, m, fn(tab, m) ->
      Multi.insert(m,
        "insert_#{tab["window"]}_#{tab["index"]}_#{timestamp}",
        Tab.changeset(%Tab{browser_id: browser.id}, tab))
    end)
    |> Multi.update(:update_timestamp, Ecto.Changeset.change(browser, last_update: timestamp))
    |> Repo.transaction()
  end

  def delete_tab(browser, tab_session_id) do
    {count, _} = from(t in Tab, where: t.session_id == ^tab_session_id and t.browser_id == ^browser.id)
    |> Repo.delete_all
    count
  end

  def upsert_tab(browser, new_tab) do
    r = case Repo.get_by(Tab, [browser_id: browser.id, session_id: new_tab["session_id"]]) do
          nil -> %Tab{browser_id: browser.id}
          tab -> tab
        end
        |> Tab.changeset(new_tab)
        |> Repo.insert_or_update

    case r do
      {:ok, new_tab} ->
        if new_tab.active do
          from(t in Tab, where: t.browser_id == ^browser.id and t.id != ^(new_tab.id))
          |> Repo.update_all(set: [active: false])
          {:ok, new_tab}
        end
      x ->
        x
    end
  end

  def create_command(source, target, payload) do
    %Command{}
    |> Command.changeset(source, target, %{payload: payload})
    |> Repo.insert
  end

  def clear_command_queue(%Browser{} = browser) do
    from(c in Command, where: c.target_id == ^browser.id) |> Repo.delete_all
  end

  def update_bookmarks(%User{} = user, %Browser{} = browser, bookmarks) do
    m = Multi.new()
    |> Multi.delete_all(:clear_old_bookmarks, from(b in Bookmark, where: b.browser_id == ^browser.id and b.user_id == ^user.id))

    Enum.reduce(bookmarks, m, fn(bookmark, m) ->
      Multi.insert(m,
        "insert_#{bookmark["url"]}_#{DateTime.utc_now()}",
        Bookmark.changeset(%Bookmark{}, user, browser, bookmark))
    end)
    |> Repo.transaction()
  end
end
