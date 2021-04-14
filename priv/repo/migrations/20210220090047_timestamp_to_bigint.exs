defmodule Domovik.Repo.Migrations.TimestampToBigint do
  use Ecto.Migration

  def change do
    alter table(:browsers) do
      modify :last_update, :bigint
    end
  end
end
