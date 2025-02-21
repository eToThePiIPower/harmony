defmodule Harmony.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Harmony.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_profiles" do
    field :avatar_path, :string
    field :display_name, :string
    field :about_me, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:avatar_path, :display_name, :about_me])
  end
end
