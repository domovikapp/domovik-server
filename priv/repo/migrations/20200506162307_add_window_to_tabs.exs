defmodule Domovik.Repo.Migrations.AddWindowToTabs do
  use Ecto.Migration

  def change do
    alter table("tabs") do
      add :window, :integer
    end
  end
end
