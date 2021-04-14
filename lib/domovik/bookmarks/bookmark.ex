defmodule Domovik.Bookmarks.Bookmark do
  @moduledoc """
  Domovik Bookmarks are but a flat copy of the bookmarks arborescence
  of each browser, as we don't want to interfere with custom workflows
  that users could have developed, only make them accesssible from
  everywhere.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :url, :string
    field :title, :string, default: ""

    belongs_to :browser, Domovik.Sync.Browser
    belongs_to :user, Domovik.Users.User
  end

  def changeset(bookmark, user, browser, attrs) do
    bookmark
    |> cast(attrs, [:url, :title])
    |> validate_required([:url])
    |> validate_length(:url, max: 8192)
    |> validate_length(:title, max: 8192)
    |> put_assoc(:browser, browser)
    |> put_assoc(:user, user)
  end
end
