defmodule Domovik.Sync.Browser do
  @moduledoc """
  Each User has several browsers, that in turn contains tabs,
  bookmarks, and commands to process.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :uuid}
  schema "browsers" do
    field :last_update, :integer
    field :name, :string
    field :uuid, :string

    belongs_to :user, Domovik.Users.User
    has_many :tabs, Domovik.Sync.Tab
    has_many :bookmarks, Domovik.Bookmarks.Bookmark
    has_many :pending_commands, Domovik.Sync.Command, foreign_key: :target_id

    timestamps()
  end

  @doc false
  def changeset(browser, attrs) do
    browser
    |> cast(attrs, [:name, :uuid, :last_update, :user_id])
    |> validate_required([:name, :uuid, :last_update, :user_id])
  end
end
