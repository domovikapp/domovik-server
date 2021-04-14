defmodule Domovik.Repo.Migrations.TabTitleToText do
  use Ecto.Migration

  def change do
    alter table(:tabs) do
      modify :title, :text
    end
  end
end
