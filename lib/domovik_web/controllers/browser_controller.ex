defmodule DomovikWeb.BrowserController do
  use DomovikWeb, :controller

  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Sync.Browser

  import Pow.Plug

  def index(conn, _params) do
    browsers = Sync.list_user_browsers(current_user(conn))
    render(conn, "index.html", browsers: browsers |> Repo.preload([:tabs]))
  end

  def new(conn, _params) do
    changeset = Sync.change_browser(%Browser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"browser" => browser_params}) do
    case Sync.create_browser(browser_params) do
      {:ok, browser} ->
        conn
        |> redirect(to: Routes.browser_path(conn, :show, browser))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => uuid}) do
    browser = Sync.get_user_browser!(uuid, current_user(conn).id) |> Repo.preload([:tabs])
    render(conn, "show.html", browser: browser)
  end

  def edit(conn, %{"id" => id}) do
    browser = Sync.get_user_browser!(id, current_user(conn).id)
    changeset = Sync.change_browser(browser)
    render(conn, "edit.html", browser: browser, changeset: changeset)
  end

  def update(conn, %{"id" => id, "browser" => browser_params}) do
    browser = Sync.get_user_browser!(id, current_user(conn).id)

    case Sync.update_browser(browser, browser_params) do
      {:ok, browser} ->
        conn
        |> redirect(to: Routes.browser_path(conn, :show, browser))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", browser: browser, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    browser = Sync.get_user_browser!(id, current_user(conn).id)
    {:ok, _browser} = Sync.delete_browser(browser)

    conn
    |> redirect(to: Routes.browser_path(conn, :index))
  end
end
