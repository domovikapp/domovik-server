defmodule DomovikWeb.ListController do
  use DomovikWeb, :controller

  alias Domovik.Repo
  alias Domovik.ReadingList
  alias Domovik.ReadingList.{List, Link}

  import Pow.Plug

  def index(conn, _params) do
    lists = current_user(conn) |> ReadingList.user_lists() |> Repo.preload(:links)
    render(conn, "index.html", lists: lists, changeset: ReadingList.change_list(%List{}))
  end

  def create(conn, %{"list" => list_params}) do
    user = current_user(conn)

    case ReadingList.create_list(user, list_params) do
      {:ok, _} ->
        redirect(conn, to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html",
          changeset: changeset,
          lists: ReadingList.user_lists(user) |> Repo.preload(:links)
        )
    end
  end

  def delete(conn, %{"id" => uuid}) do
    user = current_user(conn)
    list = ReadingList.user_list(uuid, user)

    case Repo.delete(list) do
      {:ok, _} ->
        conn

      _ ->
        conn
        |> put_flash(:error, "\"#{list.name}\" does not exist")
    end
    |> redirect(to: Routes.list_path(conn, :index))
  end

  def consume_link(conn, %{"id" => list_uuid, "link_id" => link_id, "to" => to}) do
    user = current_user(conn)

    with list when not is_nil(list) <- ReadingList.user_list(list_uuid, user),
         link when not is_nil(link) <- Repo.get_by(Link, id: link_id, list_id: list.id),
         {:ok, _link} <- ReadingList.delete_link(link) do
      conn
      |> redirect(external: to)
    else
      _ ->
        conn
        |> put_flash(:error, "This link does not exist")
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
