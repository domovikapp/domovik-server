defmodule Domovik.Users.User do
  @moduledoc """
  The Users.User module contains data related to the handling of
  users, both as Stripe clients and as Domovik users.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  import Ecto.Changeset

  schema "users" do
    pow_user_fields()

    field :customer_id, :string, default: ""
    # :subscription should one of "free", "premium", "vip"
    field :subscription, :string, default: "free"
    field :want_emails, :boolean, default: false

    has_many :reading_lists, Domovik.ReadingList.List
    has_many :bookmarks, Domovik.Bookmarks.Bookmark

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, max: 500)
    |> cast(attrs, [:want_emails])
  end
end
