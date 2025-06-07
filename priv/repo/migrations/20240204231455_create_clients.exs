defmodule Irchub.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :irchub_user_id, :integer
      add :tag, :text
      add :url, :text
      add :nick, :text
      add :full_name, :text
      add :is_enabled, :boolean, default: false, null: false
      add :channels, :text

      timestamps(type: :utc_datetime)
    end
  end
end
