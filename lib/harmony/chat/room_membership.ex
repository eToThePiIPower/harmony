defmodule Harmony.Chat.RoomMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Harmony.Accounts.User
  alias Harmony.Chat.Room

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "room_memberships" do
    belongs_to :room, Room
    belongs_to :user, User
    field :last_read_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_memberships, attrs) do
    room_memberships
    |> cast(attrs, [:last_read_id])
    |> validate_required([:last_read_id])
  end
end
