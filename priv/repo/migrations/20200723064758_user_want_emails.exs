defmodule Domovik.Repo.Migrations.UserWantEmails do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :want_emails, :boolean, default: false
    end
  end
end
