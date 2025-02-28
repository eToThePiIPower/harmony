defmodule Harmony.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Harmony.Chat.{Reply, Room}
  alias Harmony.Accounts.User

  @type t() :: %__MODULE__{
          id: UUIDv7.t(),
          body: String.t(),
          user: User.t(),
          user_id: Ecto.UUID.t(),
          room: Room.t(),
          room_id: Ecto.UUID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :body, :string
    belongs_to :user, User
    belongs_to :room, Room

    has_many :replies, Reply

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
