defmodule Harmony.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :topic, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rooms, [:name])
  end
end
