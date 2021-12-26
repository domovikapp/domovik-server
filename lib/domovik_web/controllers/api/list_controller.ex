defmodule DomovikWeb.Api.V1.ListController do
  use DomovikWeb, :controller

  alias Domovik.Repo
  alias Domovik.ReadingList
  alias Domovik.ReadingList.{List, Link}

  import Pow.Plug

  action_fallback DomovikWeb.FallbackController

  def index(conn, _params) do
    lists = current_user(conn) |> ReadingList.user_lists() |> Repo.preload(:links)
    render(conn, "index.json", lists: lists)
  end

  def create(conn, %{"name" => name}) do
    case ReadingList.create_list(current_user(conn), %{name: name}) do
      {:ok, %List{} = list} ->
        conn
        |> put_status(:created)
        |> render("show.json", list: list)

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "unable to create a list"})
    end
  end

  def show(conn, %{"id" => uuid}) do
    case ReadingList.user_list(uuid, current_user(conn)) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "list not found"})

      list ->
        render(conn, "show.json", list: list)
    end
  end

  def add_link(conn, %{"id" => uuid, "link" => link}) do
    user = current_user(conn)

    with list when not is_nil(list) <- ReadingList.user_list(uuid, user),
         {:ok, _} <- ReadingList.add_link(list, link) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_list_path(conn, :show, list))
      |> render("index.json", lists: ReadingList.user_lists(user))
    else
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "unable to create a link"})
    end
  end

  def delete_link(conn, %{"id" => list_uuid, "link_id" => link_id}) do
    user = current_user(conn)

    with list when not is_nil(list) <- ReadingList.user_list(list_uuid, user),
         link when not is_nil(link) <- Repo.get_by(Link, id: link_id, list_id: list.id),
         {:ok, _} <- ReadingList.delete_link(link) do
      send_resp(conn, :no_content, "")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "list not found"})
    end
  end
end
