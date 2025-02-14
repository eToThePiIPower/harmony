defmodule Harmony.Chat.RoomTest do
  use ExUnit.Case, async: true
  alias Harmony.Chat.Room
  import Harmony.Factory

  describe "Chat.Room:name" do
    test "validates length <= 16" do
      room = build(:room)

      changeset = Room.changeset(room, %{name: "abcdefghijklop"})
      assert changeset.valid?

      changeset = Room.changeset(room, %{name: "abcdefghijklmnopq"})
      refute changeset.valid?
    end

    test "validates existence" do
      room = build(:room)

      changeset = Room.changeset(room, %{name: ""})
      refute changeset.valid?

      changeset = Room.changeset(room, %{name: nil})
      refute changeset.valid?
    end

    test "validates contains only lowercase letters, numbers, and dashes" do
      room = build(:room)

      changeset = Room.changeset(room, %{name: "hello-world1"})
      assert changeset.valid?

      changeset = Room.changeset(room, %{name: "Hello-world1"})
      refute changeset.valid?
      assert {error, [validation: :format]} = changeset.errors[:name]
      assert error == "must contain only lowercase letters, numbers, or dashes"

      # More edge cases
      changeset = Room.changeset(room, %{name: "hello world"})
      refute changeset.valid?
      changeset = Room.changeset(room, %{name: "hell@world"})
      refute changeset.valid?
      changeset = Room.changeset(room, %{name: "hello🌎"})
      refute changeset.valid?
    end
  end
end
