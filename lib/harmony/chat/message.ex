defmodule Harmony.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    belongs_to :user, Harmony.Account.User
    belongs_to :room, Harmony.Chat.Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :user_id, :room_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:room_id)
    |> validate_required([:body, :user_id, :room_id])
  end
end
