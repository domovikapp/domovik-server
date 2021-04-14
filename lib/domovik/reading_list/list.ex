defmodule Domovik.ReadingList.List do
  @moduledoc """
  A ReadingList has a title and a set of links. A default one is
  created as soon as a user registers.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive{Phoenix.Param, key: :uuid}
  schema "reading_lists" do
    field :uuid, :string
    field :name, :string

    belongs_to :user, Domovik.Users.User
    has_many :links, Domovik.ReadingList.Link

    timestamps()
  end

  @doc false
  def changeset(reading_list, attrs) do
    reading_list
    |> cast(attrs, [:uuid, :name, :user_id])
    |> validate_required([:uuid, :name, :user_id])
  end
end
