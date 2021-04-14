defmodule Domovik.Repo.Migrations.AddActiveToTabs do
  use Ecto.Migration

  def change do
    alter table("tabs") do
      add :active, :boolean
    end
  end
end
