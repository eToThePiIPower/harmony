defmodule Harmony.Chat do
  alias Harmony.Repo
  alias Harmony.Accounts.User
  alias Harmony.Chat.{Message, Room, RoomMembership}

  import Ecto.Changeset
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

  def update_room(%User{role: :admin}, %Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def update_room(%User{}, %Room{}, _attrs) do
    {:error, :not_authorized}
  end

  def subscribe_to_room(room) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room.id))
  end

  def unsubscribe_from_room(room) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(room.id))
  end

  def get_last_read_id(%Room{} = room, %User{} = user) do
    case Repo.get_by(RoomMembership, room_id: room.id, user_id: user.id) do
      %RoomMembership{last_read_id: last_read_id} ->
        last_read_id

      nil ->
        nil
    end
  end

  def update_last_read_id(%Room{} = room, %User{} = user) do
    case Repo.get_by(RoomMembership, room_id: room.id, user_id: user.id) do
      %RoomMembership{} = membership ->
        id =
          from(m in Message,
            where: m.room_id == ^room.id,
            select: max(type(m.id, :string))
          )
          |> Repo.one()

        membership
        |> change(%{last_read_id: id})
        |> Repo.update()

      nil ->
        nil
    end
  end

  # Chat.RoomMembership

  def join_room!(%Room{} = room, %User{} = user) do
    %RoomMembership{room: room, user: user}
    |> Repo.insert!()
  end

  def list_joined_rooms(%User{} = user) do
    user
    |> Repo.preload(:rooms)
    |> Map.fetch!(:rooms)
    |> Enum.sort_by(& &1.name)
  end

  def list_joined_rooms_with_unread_counts(%User{} = user) do
    from(room in Room,
      join: membership in assoc(room, :memberships),
      where: membership.user_id == ^user.id,
      left_join: message in assoc(room, :messages),
      on: message.id > membership.last_read_id,
      group_by: [room.id, membership.id],
      select: {room, count(message.id), is_nil(membership.last_read_id)},
      order_by: [asc: room.name]
    )
    |> Repo.all()
  end

  def joined?(%Room{} = room, %User{} = user) do
    Repo.exists?(
      from r_m in RoomMembership, where: r_m.room_id == ^room.id and r_m.user_id == ^user.id
    )
  end

  def list_rooms_with_joined(%User{} = user) do
    query =
      from room in Room,
        left_join: membership in RoomMembership,
        on: room.id == membership.room_id and ^user.id == membership.user_id,
        select: {room, not is_nil(membership.id)},
        order_by: [asc: room.name]

    Repo.all(query)
  end

  def toggle_room_membership(%Room{} = room, %User{} = user) do
    case Repo.get_by(RoomMembership, room_id: room.id, user_id: user.id) do
      %RoomMembership{} = membership ->
        Repo.delete(membership)
        {room, false}

      nil ->
        join_room!(room, user)
        {room, true}
    end
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
    with true <- joined?(room, user),
         {:ok, message} <-
           %Message{user: user, room: room}
           |> Message.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast!(@pubsub, topic(room.id), {:new_message, message})
      {:ok, message}
    else
      false -> {:error, :unauthorized}
      {:error, changset} -> {:error, changset}
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
