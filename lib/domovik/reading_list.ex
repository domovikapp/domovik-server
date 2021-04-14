defmodule Domovik.ReadingList do
  @moduledoc """
  This module contains all the structures and functions linked to the handling of reading lists
  and the links they contain.
  """

  import Ecto.Query, warn: false
  alias Domovik.Repo

  alias Domovik.ReadingList.{List, Link}

  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end


  def user_lists(user) do
    Repo.all(from l in List, where: l.user_id == ^user.id)
  end

  def user_list(uuid, user), do: Repo.get_by(List, [uuid: uuid, user_id: user.id])

  def create_list(user, attrs \\ %{}) do
    %List{uuid: UUID.uuid1(), user_id: user.id}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def add_link(list, link_attrs) do
    %Link{list_id: list.id}
    |> Link.changeset(link_attrs)
    |> Repo.insert()
  end

  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end
end
