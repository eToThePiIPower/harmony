defmodule Harmony.Chat do
  alias Harmony.{Chat.Room, Chat.Message, Repo}
  alias Harmony.Accounts.User
  import Ecto.Query

  # Chat.Room

  def list_rooms do
    from(Room)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def get_room(name) do
    Repo.get_by(Room, name: name)
  end

  def default_room do
    from(Room)
    |> first(:inserted_at)
    |> Repo.one()
  end

  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  # Chat.Message

  def list_messages(%Room{id: room_id}) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end

  def change_message(message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(%User{} = user, %Room{} = room, attrs) do
    %Message{user: user, room: room}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end
end
