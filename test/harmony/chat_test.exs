defmodule Harmony.ChatTest do
  use Harmony.DataCase
  import Harmony.Factory

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
end
