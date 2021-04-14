defmodule Domovik.Repo.Migrations.CreateCommand do
  use Ecto.Migration

  def change do
    create table(:commands) do
      add :source_id, references(:browsers, on_delete: :delete_all)
      add :target_id, references(:browsers, on_delete: :delete_all)
      add :payload, :jsonb

      timestamps()
    end

    create index(:commands, [:target_id])
  end
end
