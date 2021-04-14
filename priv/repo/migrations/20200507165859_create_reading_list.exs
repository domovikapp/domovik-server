defmodule Domovik.Repo.Migrations.CreateReadingList do
  use Ecto.Migration

  def change do
    create table(:reading_lists) do
      add :name, :string
      add :uuid, :string

      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create table(:reading_links) do
      add :url, :text
      add :favicon, :text
      add :title, :string

      add :list_id, references(:reading_lists, on_delete: :delete_all)
    end
  end
end
