defmodule Harmony.Repo.Migrations.CreateReplies do
  use Ecto.Migration

  def change do
    create table(:replies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text, null: false
      add :message_id, references(:messages, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:replies, [:message_id])
    create index(:replies, [:user_id])
  end
end
