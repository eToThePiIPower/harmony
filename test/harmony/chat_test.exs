defmodule Harmony.ChatTest do
  use Harmony.DataCase
  import Harmony.Factory

  alias Harmony.Chat

  describe "rooms" do
    test "list_room/0 returns all rooms" do
      [room1, room2] = insert_pair(:room)

      assert Chat.list_rooms() == [room1, room2]
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
  end
end
