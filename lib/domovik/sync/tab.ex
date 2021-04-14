defmodule Domovik.Sync.Tab do
  @moduledoc """
  A Tab represents a tab from a browser. Thus, it features a few
  intrinsinc charateristic such as URL and title, as well as a link
  (and backlinks) to a browser.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "tabs" do
    field :session_id, :integer, default: 0
    field :window, :integer, default: 0
    field :index, :integer, default: 0
    field :title, :string
    field :url, :string
    field :favicon, :string, default: ""
    field :active, :boolean, default: false
    field :pinned, :boolean, default: false

    belongs_to :browser, Domovik.Sync.Browser

    timestamps()
  end

  @doc false
  def changeset(tab, attrs) do
    tab
    |> cast(attrs, [:url, :favicon, :title, :browser_id, :active, :index, :pinned, :window, :session_id])
    |> validate_required([:url, :title, :browser_id])
    |> validate_length(:url, max: 8192)
    |> validate_length(:title, max: 8192)
    |> validate_length(:favicon, max: 50_000)
  end
end
