defmodule Harmony.Chat do
  alias Harmony.{Chat.Room, Chat.Message, Repo}
  alias Harmony.Accounts.User
  import Ecto.Query

  @pubsub Harmony.PubSub

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

  def create_room(%User{role: :admin}, attrs) do
    Room.changeset(%Room{}, attrs)
    |> Repo.insert()
  end

  def create_room(%User{}, _attrs) do
    {:error, :not_authorized}
  end

  def delete_room_by_id(%User{role: :admin}, id) do
    Repo.get(Room, id)
    |> Repo.delete()
  end

  def delete_room_by_id(%User{}, _attrs) do
    {:error, :not_authorized}
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def subscribe_to_room(room) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room.id))
  end

  def unsubscribe_from_room(room) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(room.id))
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
    with {:ok, message} <-
           %Message{user: user, room: room}
           |> Message.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast!(@pubsub, topic(room.id), {:new_message, message})
      {:ok, message}
    end
  end

  def delete_message_by_id(id, %User{id: user_id}) do
    case Repo.get(Message, id) do
      %Message{user_id: ^user_id} = message ->
        Phoenix.PubSub.broadcast!(@pubsub, topic(message.room_id), {:delete_message, message})
        Repo.delete(message)

      _ ->
        {:error, "Message does not exist or is not owned by user"}
    end
  end

  defp topic(room_id), do: "chat_room:#{room_id}"
end
