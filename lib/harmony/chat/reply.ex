defmodule Harmony.Chat.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  alias Harmony.Accounts.User
  alias Harmony.Chat.Message

  @type t() :: %__MODULE__{
          id: UUIDv7.t(),
          body: String.t(),
          user: User.t(),
          user_id: Ecto.UUID.t(),
          message: Message.t(),
          message: UUIDv7.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "replies" do
    field :body, :string

    belongs_to :message, Message
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
