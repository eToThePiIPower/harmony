defmodule Harmony.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Harmony.Chat.Room
  alias Harmony.Accounts.User

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :body, :string
    belongs_to :user, User
    belongs_to :room, Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
