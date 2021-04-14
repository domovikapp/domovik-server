defmodule Domovik.Repo.Migrations.LinkStripe do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :customer_id, :string
    end

    create unique_index(:users, [:customer_id])
  end
end
