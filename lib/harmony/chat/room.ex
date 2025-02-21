defmodule Harmony.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Harmony.Accounts.User
  alias Harmony.Chat.{Message, RoomMembership}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :name, :string
    field :topic, :string

    has_many :messages, Message
    has_many :memberships, RoomMembership

    many_to_many :members, User, join_through: RoomMembership

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
