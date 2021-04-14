defmodule Domovik.Repo.Migrations.TabAddSessionId do
  use Ecto.Migration

  def change do
    alter table("tabs") do
      add :session_id, :integer
    end
  end
end
