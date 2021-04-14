defmodule Domovik.Repo.Migrations.ExtendLink do
  use Ecto.Migration

  def change do
    alter table(:reading_links) do
      modify :title, :text
    end
  end
end
