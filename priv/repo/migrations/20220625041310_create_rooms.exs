defmodule Harmony.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :title, :string
      add :description, :string

      timestamps()
    end
  end
end
