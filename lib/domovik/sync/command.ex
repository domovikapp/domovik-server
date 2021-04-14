defmodule Domovik.Sync.Command do
  @moduledoc """
  A Command is an instruction that is waiting to be delivered to the
  target browser from the source browser. For now, it is mostly used
  in tab sending, but could be easily extended to satisfy more uses
  thanks to its flexible structure.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Domovik.Sync.Browser

  schema "commands" do
    field :payload, :map, default: %{}

    belongs_to :source, Browser, foreign_key: :source_id
    belongs_to :target, Browser, foreign_key: :target_id

    timestamps()
  end

  def changeset(command, %Browser{} = source, %Browser{} = target, attrs) do
    command
    |> cast(attrs, [:payload])
    |> validate_required([:payload])
    |> put_assoc(:source, source)
    |> put_assoc(:target, target)
    # |> validate_length(:payload, max: 10000)
  end
end
