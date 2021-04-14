defmodule Domovik.Repo.Migrations.CreateBrowsers do
  use Ecto.Migration

  def change do
    create table(:browsers) do
      add :name, :string
      add :uuid, :string
      add :last_update, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:browsers, [:uuid])
  end
end
