defmodule DomovikWeb.Api.V1.BrowserController do
  import Ecto.Query, warn: false
  use DomovikWeb, :controller

  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Sync.Browser

  import Pow.Plug

  action_fallback DomovikWeb.FallbackController

  defp too_many_browsers(user) do
    free_browsers_count = Application.get_env(:domovik, :free_browsers)
    browsers_count = Repo.one(from b in Browser,
      where: b.user_id == ^user.id,
      select: count(b.id))

    user.subscription == "free" and browsers_count > free_browsers_count
  end

  def index(conn, _params) do
    browsers = Sync.list_user_browsers(current_user(conn)) |> Repo.preload(:tabs)
    render(conn, "index.json", browsers: browsers)
  end

  def create(conn, %{"name" => name} = _params) do
    user = current_user(conn)
    if too_many_browsers(user) do
      conn
      |> put_status(:payment_required)
      |> json(%{error: "maximum browsers count reached"})
    else
      with {:ok, browser} <- Sync.create_browser(user, %{name: name}) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.api_browser_path(conn, :show, browser))
        |> render("show.json", browser: browser)
      end
    end
  end

  def show(conn, %{"id" => uuid}) do
    user = current_user(conn)
    browser = Sync.get_user_browser!(uuid, user.id)
    render(conn, "show.json", browser: browser |> Repo.preload([:tabs]))
  end

  def update(conn, %{"id" => uuid, "name" => new_name}) do
    user = current_user(conn)
    browser = Sync.get_user_browser!(uuid, user.id)

    with {:ok, %Browser{} = browser} <- Sync.update_browser(browser, %{name: new_name}) do
      render(conn, "show.json", browser: browser)
    end
  end

  def sync_tabs(conn, %{"uuid" => uuid, "timestamp" => timestamp, "tabs" => tabs}) do
    user = current_user(conn)

    case Sync.get_user_browser!(uuid, user.id) do
      browser when not is_nil(browser) ->
        if timestamp > browser.last_update do
          Sync.update_tabs(browser, tabs, timestamp)
        end
        render(conn, "show.json", browser: browser)

      nil ->
        conn
        |> put_status(:gone)
        |> json(%{error: "unlinked"})
    end
  end

  def upsert_tab(conn, %{"uuid" => uuid, "tab" => tab}) do
    user = current_user(conn)

    with browser <- Sync.get_user_browser!(uuid, user.id),
         {:ok, _} <- Sync.upsert_tab(browser, tab) do
      send_resp(conn, :ok, "")
    end
  end

  def delete_tab(conn, %{"uuid" => uuid, "tab_session_id" => session_id}) do
    user = current_user(conn)

    case Sync.get_user_browser!(uuid, user.id) do
      browser when not is_nil(browser) ->
        if Sync.delete_tab(browser, session_id) > 0 do
          conn |> send_resp(:ok, "")
        else
          conn |> send_resp(:not_found, "")
        end
      nil ->
        conn
        |> put_status(:gone)
        |> json(%{error: "unlinked"})
    end
  end

  def new_command(conn, %{"id" => uuid, "target" => target_uuid, "command" => command}) do
    user = current_user(conn)

    with source when not is_nil(source) <- Sync.get_user_browser!(uuid, user.id),
         target when not is_nil(target) <- Sync.get_user_browser!(target_uuid, user.id),
         {:ok, _} <- Sync.create_command(source, target, command) do
      conn
      |> send_resp(:ok, "")
    else
      _ ->
        conn
        |> put_status(:gone)
        |> json(%{error: "source or target not found"})
    end
  end

  def get_pending(conn, %{"id" => uuid}) do
    user = current_user(conn)

    case Sync.get_user_browser!(uuid, user.id) do
      source when not is_nil(source) ->
        source = Repo.preload(source, :pending_commands)
        Sync.clear_command_queue(source)

        render(conn, "pending.json", browser: source)

      nil ->
        conn
        |> put_status(:gone)
        |> json(%{error: "browser not found"})
    end
  end

  def delete(conn, %{"id" => uuid}) do
    user = current_user(conn)
    browser = Sync.get_user_browser!(uuid, user.id)

    with {:ok, _} <- Sync.delete_browser(browser) do
      send_resp(conn, :no_content, "")
    end
  end
end
