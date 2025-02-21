defmodule Harmony.ChatTest do
  use Harmony.DataCase
  import Harmony.Factory
  import Harmony.AccountsFixtures

  alias Harmony.Chat

  describe "rooms" do
    test "list_room/0 returns all rooms, alphabetically" do
      room1 = insert(:room, name: "C room")
      room2 = insert(:room, name: "X room")
      room3 = insert(:room, name: "A room")
      room4 = insert(:room, name: "M room")

      assert Chat.list_rooms() == [room3, room1, room4, room2]
    end

    test "get_room/1 returns a room by name" do
      room = insert(:room)

      assert Chat.get_room(room.name) == room
    end

    test "get_room/1 returns nil when not found" do
      assert Chat.get_room("invalid") == nil
    end

    test "default_room/0 returns the first room" do
      room1 = insert(:room)
      insert_pair(:room)

      assert Chat.default_room() == room1
    end

    test "change_room/2" do
      room = build(:room)
      new_attrs = %{name: "new-name"}

      assert changeset = %Ecto.Changeset{} = Chat.change_room(room, new_attrs)
      assert changeset.changes.name == "new-name"
    end

    test "update_room/2 as admin with valid params updates a room" do
      room = insert(:room)
      user = user_fixture() |> set_role(:admin)
      new_attrs = %{name: "new-name"}

      assert {:ok, new_room} = Chat.update_room(user, room, new_attrs)
      assert new_room.name == "new-name"
    end

    test "update_room/2 as non-admin  returns an error tuple" do
      room = insert(:room)
      user = user_fixture()
      new_attrs = %{name: "new-name"}

      assert {:error, :not_authorized} = Chat.update_room(user, room, new_attrs)
    end

    test "create_room/2 creates a room" do
      user = user_fixture() |> set_role(:admin)
      attrs = params_for(:room)

      {:ok, room} = Chat.create_room(user, attrs)
      assert room.name == attrs.name
      assert room.topic == attrs.topic
    end

    test "create_room/2 non-admins return an error tuple" do
      user = user_fixture()
      attrs = params_for(:room)

      assert {:error, :not_authorized} = Chat.create_room(user, attrs)
    end

    test "delete_room/2 creates a room" do
      user = user_fixture() |> set_role(:admin)
      %Chat.Room{id: id, name: name} = insert(:room)

      assert {:ok, %Chat.Room{id: ^id}} = Chat.delete_room_by_id(user, id)
      assert Chat.get_room(name) == nil
    end

    test "delete_room/2 non-admins return an error tuple" do
      user = user_fixture()
      room = insert(:room)

      assert {:error, :not_authorized} = Chat.delete_room_by_id(user, room.id)
      refute Chat.get_room(room.name) == nil
    end

    test "update_last_read_id/2 updates the last read message id for a user in a room" do
      user = user_fixture()
      room = insert(:room)
      message = insert(:message, room: room)
      Chat.join_room!(room, user)

      id = message.id
      assert Chat.get_last_read_id(room, user) == nil
      assert {:ok, %Chat.RoomMembership{last_read_id: ^id}} = Chat.update_last_read_id(room, user)
    end
  end

  describe "room_memberships" do
    test "join_room!/2 adds a room membership for a user" do
      room = insert(:room)
      user = user_fixture()

      assert %Harmony.Chat.RoomMembership{room: ^room, user: ^user, last_read_id: lr} =
               Chat.join_room!(room, user)

      assert lr == nil
    end

    test "list_joined_rooms/1 lists the rooms a user has joined" do
      [room1, room2] = insert_pair(:room)
      [other_room1, other_room2] = insert_pair(:room)
      user = user_fixture()

      Chat.join_room!(room1, user)
      Chat.join_room!(room2, user)
      joined_rooms = Chat.list_joined_rooms(user)

      assert room1 in joined_rooms
      assert room2 in joined_rooms
      refute other_room1 in joined_rooms
      refute other_room2 in joined_rooms
    end

    test "list_joined_rooms/1 sorts by room name" do
      [room1, room2] = insert_pair(:room)
      aard = insert(:room, name: "aardvark")
      user = user_fixture()

      Chat.join_room!(room1, user)
      Chat.join_room!(room2, user)
      Chat.join_room!(aard, user)
      [first | _rest] = joined_rooms = Chat.list_joined_rooms(user)

      assert aard in joined_rooms
      assert first == aard
    end

    test "list_joined_rooms_with_unread/1" do
      user = user_fixture()

      room1 =
        insert(:room)
        |> with_messages(count: 2)
        |> read_messages(user)

      [room2, room3] =
        insert_pair(:room)
        |> with_messages(count: 2)
        |> read_messages(user)
        |> with_messages(count: 2)

      room4 = insert(:room) |> with_messages(count: 3)
      Chat.join_room!(room4, user)

      list = Chat.list_joined_rooms_with_unread_counts(user)

      assert {room1, 0} in list
      assert {room2, 2} in list
      assert {room3, 2} in list
      assert {room4, 0} in list
    end

    test "joined?/2 returns if a user is a member of a room" do
      user = user_fixture()
      room = insert(:room)
      other_room = insert(:room)
      Chat.join_room!(room, user)

      assert Chat.joined?(room, user)
      refute Chat.joined?(other_room, user)
    end

    test "list_rooms_with_joins/1 lists all of the servers rooms, along with the given users join status" do
      user = user_fixture()
      [room1, room2] = insert_pair(:room)
      other_room = insert(:room)
      aard = insert(:room, name: "aaardvark")
      Chat.join_room!(room1, user)
      Chat.join_room!(room2, user)

      rooms_with_joined = Chat.list_rooms_with_joined(user)

      assert {room1, true} in rooms_with_joined
      assert {room2, true} in rooms_with_joined
      assert {other_room, false} in rooms_with_joined

      # It alphabetized the list
      assert rooms_with_joined |> List.first() == {aard, false}
    end

    test "toggle_room_membership/2 toggles a room membership for a user" do
      room = insert(:room)
      user = user_fixture()

      refute Chat.joined?(room, user)
      assert Chat.toggle_room_membership(room, user) == {room, true}
      assert Chat.joined?(room, user)
      assert Chat.toggle_room_membership(room, user) == {room, false}
      refute Chat.joined?(room, user)
    end
  end

  describe "messages" do
    test "list_messages/1 returns all messages for a room" do
      room = insert(:room)
      insert_list(3, :message, room: room)

      other_room = insert(:room)
      insert_list(3, :message, room: other_room)

      messages = Chat.list_messages(room)
      assert length(messages) == 3
    end

    test "create_message/3 create a message" do
      user = user_fixture()
      room = insert(:room)
      Chat.join_room!(room, user)
      params = params_for(:message, body: "Test message body")
      Chat.subscribe_to_room(room)

      {:ok, message} = Chat.create_message(user, room, params)
      assert_receive({:new_message, ^message})
      assert message.body == "Test message body"
    end

    test "create_message/3 user must be joined" do
      user = user_fixture()
      room = insert(:room)
      params = params_for(:message, body: "Test message body")
      Chat.subscribe_to_room(room)

      {:error, :unauthorized} = Chat.create_message(user, room, params)
      refute_receive({:new_message, _})
    end

    test "change_message/2 returns a valid changeset" do
      user = user_fixture()
      room = insert(:room)
      message = %Chat.Message{room: room, user: user}
      new_attrs = %{body: "message body"}

      assert changeset = %Ecto.Changeset{} = Chat.change_message(message, new_attrs)
      assert changeset.changes.body == "message body"
      assert changeset.valid?
    end

    test "delete_message_by_id/2 delete a message with id && user" do
      user = user_fixture()
      room = insert(:room)
      message = insert(:message, user: user, room: room)
      id = message.id
      Chat.subscribe_to_room(room)

      assert [%Chat.Message{id: ^id}] = Chat.list_messages(room)
      assert {:ok, %Chat.Message{}} = Chat.delete_message_by_id(message.id, user)
      assert_receive({:delete_message, %Chat.Message{id: ^id}})
      assert [] == Chat.list_messages(room)
    end

    test "delete_message_by_id/2 does not delete a message with wrong user" do
      user = user_fixture()
      room = insert(:room)
      message = insert(:message, room: room)
      id = message.id
      Chat.subscribe_to_room(room)

      assert [%Chat.Message{id: ^id}] = Chat.list_messages(room)
      assert {:error, _} = Chat.delete_message_by_id(message.id, user)
      refute_receive({:delete_message, %Chat.Message{id: ^id}})
      assert [%Chat.Message{id: ^id}] = Chat.list_messages(room)
    end
  end
end
