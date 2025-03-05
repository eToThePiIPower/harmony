defmodule Harmony.Chat do
  alias Harmony.Repo
  alias Harmony.Accounts.User
  alias Harmony.Chat.{Message, Room, RoomMembership}

  import Ecto.Changeset
  import Ecto.Query

  @pubsub Harmony.PubSub

  # Chat.Room

  @spec list_rooms() :: list(Room.t())
  def list_rooms do
    from(Room)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  @spec get_room(String.t()) :: Room.t() | nil
  def get_room(name) do
    Repo.get_by(Room, name: name)
  end

  @spec default_room() :: Room.t() | nil
  def default_room do
    from(Room)
    |> first(:inserted_at)
    |> Repo.one()
  end

  @spec change_room(Room.t(), map()) :: Ecto.Changeset.t(Room.t())
  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @spec create_room(User.t(:admin), map()) ::
          {:ok, Room.t()} | {:error, Ecto.Changeset.t(Room.t())} | {:error, :not_authorized}
  def create_room(%User{role: :admin}, attrs) do
    Room.changeset(%Room{}, attrs)
    |> Repo.insert()
  end

  def create_room(%User{}, _attrs) do
    {:error, :not_authorized}
  end

  @spec delete_room_by_id(User.t(), Ecto.UUID.t()) ::
          {:ok, Room.t()} | {:error, Ecto.Changeset.t(Room.t())} | {:error, :not_authorized}
  def delete_room_by_id(%User{role: :admin}, id) do
    Repo.get(Room, id)
    |> Repo.delete()
  end

  def delete_room_by_id(%User{}, _attrs) do
    {:error, :not_authorized}
  end

  @spec update_room(User.t(), Room.t(), map()) ::
          {:ok, Room.t()} | {:error, Ecto.Changeset.t(Room.t())} | {:error, :not_authorized}
  def update_room(%User{role: :admin}, %Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def update_room(%User{}, %Room{}, _attrs) do
    {:error, :not_authorized}
  end

  @doc """
  Subscribes to the PubSub topic for a given room.

  ## Important

  The BEAM *will* let you subscribe multiple times to the same
  topic, which will result in multiple messsages coming in for each event, so
  you have to be careful to call this only once per topic (unless you unsubscribe later).
  """
  @spec subscribe_to_room(Room.t()) :: :ok | {:error, term()}
  def subscribe_to_room(room) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room.id))
  end

  @doc """
  Unsubscribes to the PubSub topic for a given room.

  ## Important

  The BEAM *will* let you subscribe multiple times to the same
  topic, which will result in multiple messsages coming in for each event
  but unsubscribing will unsubscribe from *all* the subscriptions to the same
  topic.;
  """
  @spec unsubscribe_from_room(Room.t()) :: :ok
  def unsubscribe_from_room(room) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(room.id))
  end

  @spec get_last_read_id(Room.t(), User.t()) :: UUIDv7.t() | nil
  def get_last_read_id(%Room{} = room, %User{} = user) do
    case Repo.get_by(RoomMembership, room_id: room.id, user_id: user.id) do
      %RoomMembership{last_read_id: last_read_id} ->
        last_read_id

      nil ->
        nil
    end
  end

  # Chat.RoomMembership

  @doc """
  Updates the `last_read_id` for the `RoomMembership` associated with the given
  `Room` and `User` to the current maximum id of the `messages` belonging to
  the given `Room`.`

  As the `Message` schema uses UUIDv7 for it's id, we know that the ids are
  monotonically (mostly, with microsecond granularity) increasing, so simply
  picking the maximum is sufficient.
  """
  @spec update_last_read_id(Room.t(), User.t()) :: {:ok, RoomMembership.t()} | :noop
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
        :noop
    end
  end

  @spec join_room!(Room.t(), User.t()) :: any()
  def join_room!(%Room{} = room, %User{} = user) do
    %RoomMembership{room: room, user: user}
    |> Repo.insert!()
  end

  @spec list_joined_rooms(User.t()) :: list(Room.t())
  def list_joined_rooms(%User{} = user) do
    user
    |> Repo.preload(:rooms)
    |> Map.fetch!(:rooms)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  List of the rooms joined by the given user, along with a count of "unread"
  messages, and whether or not the `last_read_is` is nil.

  ## Return
  A list of tuples of the form `{room, count, last_read?}`, where:
  - room: a `%Chat.Room{}`
  - count: a non-negative integer representing the number of unread messages
  - `last_read?`: a boolean representing if last_read_id is nil (i.e. if the
    User is new to the Room)
    - `true`: if the `last_read_id` was `nil` (the Room is new to the User)
    - `false`: if the `last_read_id` was set (the Room is not new to the User)

  `last_read?` should *always* be `false` if `count` is non-zero.

  ## Example
    iex> Chat.list_joined_rooms_with_unread_counts(user)
    [
      {room1, 0, false},
      {room2, 10, false},
      {newly_joined_room, 0, true}
    ]
  """
  @spec list_joined_rooms_with_unread_counts(User.t()) ::
          list({Room.t(), non_neg_integer(), boolean()})
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

  @spec joined?(Room.t(), User.t()) :: boolean()
  def joined?(%Room{} = room, %User{} = user) do
    Repo.exists?(
      from r_m in RoomMembership, where: r_m.room_id == ^room.id and r_m.user_id == ^user.id
    )
  end

  @doc """
  Lists all of the rooms on the serve visible to the given User, along with
  whether that user has joined the room.

  ## Return
  A list of tuples of the form `{room, joined?}`, where:
  - room: a `%Chat.Room{}`
  - joined? a boolean representing if the given User has joined the above Room
    - `true`: A `RoomMembership` exisits for the User and the above Room`
    - `false`: A `RoomMembership` does not exisit for the User and the above Room`
  """
  @spec list_rooms_with_joined(User.t()) :: list({Room.t(), boolean()})
  def list_rooms_with_joined(%User{} = user) do
    query =
      from room in Room,
        left_join: membership in RoomMembership,
        on: room.id == membership.room_id and ^user.id == membership.user_id,
        select: {room, not is_nil(membership.id)},
        order_by: [asc: room.name]

    Repo.all(query)
  end

  @doc """
  Creates or deletes the RoomMembership relationship for the given Room-User pair.

  ## Return
  A tuple of the form `{Room, joined?}` where:
  - room: the `%Chat.Room{}`
  - joined?: a boolean
    - `true`: the RoomMembership has been created
    - `false`: the RoomMembership has been deleted
  """
  @spec toggle_room_membership(Room.t(), User.t()) :: {Room.t(), boolean()}
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

  @spec list_messages(Room.t()) :: list(Message.t())
  def list_messages(%Room{id: room_id}) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end

  @spec change_message(Message.t(), map()) :: Ecto.Changeset.t(Message.t())
  def change_message(message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  @spec create_message(User.t(), Room.t(), map()) ::
          {:ok, Message.t()} | {:error, Ecto.Changeset.t(Message.t())} | {:error, :unauthorized}
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

  @spec delete_message_by_id(UUIDv7.t(), User.t()) :: {:ok, Message.t()} | {:error, String.t()}
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
