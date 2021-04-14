defmodule Domovik.Repo.Migrations.SubscriptionActive do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :subscription, :string
    end
  end
end
