defmodule Domovik.Repo.Migrations.CreateTabs do
  use Ecto.Migration

  def change do
    create table(:tabs) do
      add :url, :text
      add :favicon, :text
      add :title, :string
      add :index, :integer
      add :browser_id, references(:browsers, on_delete: :delete_all)

      timestamps()
    end

    create index(:tabs, [:browser_id])
  end
end
