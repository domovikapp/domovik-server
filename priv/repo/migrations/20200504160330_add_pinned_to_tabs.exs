defmodule Domovik.Repo.Migrations.AddPinnedToTabs do
  use Ecto.Migration

  def change do
    alter table("tabs") do
      add :pinned, :boolean
    end
  end
end
