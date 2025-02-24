defmodule Harmony.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :avatar_path, :string
      add :display_name, :string
      add :about_me, :text
      add :user_id, references(:users, on_delete: :restrict, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    execute """
            INSERT INTO user_profiles (id, user_id, display_name, inserted_at, updated_at)
            SELECT gen_random_uuid(), id, username, inserted_at, NOW()
            FROM users;
            """,
            ""

    create unique_index(:user_profiles, [:user_id])
  end
end
