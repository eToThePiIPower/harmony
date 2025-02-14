defmodule Harmony.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :name, :string
    field :topic, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :topic])
    |> validate_required([:name, :topic])
    |> unsafe_validate_unique(:name, Harmony.Repo)
    |> unique_constraint(:name)
    |> validate_length(:name, max: 16)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/,
      message: "must contain only lowercase letters, numbers, or dashes"
    )
    |> validate_length(:topic, max: 80)
  end
end
