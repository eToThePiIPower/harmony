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

    test "update_room/2 with valid params updates a room" do
      room = insert(:room)
      new_attrs = %{name: "new-name"}

      assert {:ok, new_room} = Chat.update_room(room, new_attrs)
      assert new_room.name == "new-name"
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
      params = params_for(:message, body: "Test message body")

      {:ok, message} = Chat.create_message(user, room, params)
      assert message.body == "Test message body"
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
  end
end
