defmodule Domovik.ReadingList.Link do
  @moduledoc """
  The Links of a ReadingList are nothing unusual, except that they
  disappear after having been opened.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "reading_links" do
    field :url, :string
    field :favicon, :string, default: ""
    field :title, :string, default: ""

    belongs_to :list, Domovik.ReadingList.List
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :favicon, :title])
    |> validate_required([:url])
    |> validate_length(:url, max: 8192)
    |> validate_length(:title, max: 8192)
    |> validate_length(:favicon, max: 50_000)
  end
end
