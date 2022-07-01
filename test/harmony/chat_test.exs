defmodule Harmony.ChatTest do
  use Harmony.DataCase

  alias Harmony.Chat
  import Harmony.Factory

  describe "rooms" do
    alias Harmony.Chat.Room

    import Harmony.ChatFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Chat.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Chat.get_room!(room.id) == room
    end

    test "get_room_by_name!/1 returns the room with given title" do
      room = room_fixture()
      assert Chat.get_room_by_name!(room.title) == room
    end

    test "preload_room_messages/1 sorts & loads the rooms messages with users" do
      room = insert(:room)
      user = insert(:user)
      [m1, m2] = insert_list(2, :message, %{room: room, user: user})

      returned_room =  Chat.get_room_by_name!(room.title) |> Chat.preload_room_messages
      [returned_m1, returned_m2] = returned_room.messages

      assert returned_m1.id == m1.id
      assert returned_m2.body == m2.body
      assert returned_m2.user.email == user.email
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{description: "some description", title: "some title"}

      assert {:ok, %Room{} = room} = Chat.create_room(valid_attrs)
      assert room.description == "some description"
      assert room.title == "some title"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Room{} = room} = Chat.update_room(room, update_attrs)
      assert room.description == "some updated description"
      assert room.title == "some updated title"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_room(room, @invalid_attrs)
      assert room == Chat.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chat.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Chat.change_room(room)
    end
  end

  describe "messages" do
    alias Harmony.Chat.Message

    import Harmony.Factory

    @invalid_attrs %{body: nil}

    test "list_messages/0 returns all messages" do
      message = insert(:message)
      [listed_message] = Chat.list_messages()
      assert equal_records listed_message, message
      assert listed_message == message |> forget(:user) |> forget(:room)
    end

    test "get_message!/1 returns the message with given id" do
      message = insert(:message)
      assert Chat.get_message!(message.id) == message |> forget(:user) |> forget(:room)
    end

    test "create_message/1 with valid data creates a message" do
      user = insert(:user)
      room = insert(:room)
      valid_attrs = %{body: "some body", user_id: user.id, room_id: room.id}

      assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
      assert message.body == "some body"
      assert message.user.email == user.email
      assert message.room.title == room.title
    end

    test "create_message/1 with invalid data returns error changeset" do
      user = insert(:user)
      attrs = @invalid_attrs |> Map.put(:user_id, user.id)

      assert {:error, %Ecto.Changeset{} = changeset} = Chat.create_message(attrs)

      {body_errors, _} = changeset.errors[:body]
      {room_errors, _} = changeset.errors[:room_id]
      assert body_errors == "can't be blank"
      assert room_errors == "can't be blank"
    end

    test "create_message/1 with invalid associations returns error changeset" do
      user = insert(:user)
      attrs = %{body: "valid message"} |> Map.put(:user_id, user.id) |> Map.put(:room_id, 0)

      assert {:error, %Ecto.Changeset{} = changeset} = Chat.create_message(attrs)
      {room_errors, _} = changeset.errors[:room_id]
      assert room_errors == "does not exist"
    end

    test "update_message/2 with valid data updates the message" do
      message = insert(:message)
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Message{} = message} = Chat.update_message(message, update_attrs)
      assert message.body == "some updated body"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = insert(:message)
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert Chat.get_message!(message.id) == message |> forget(:user) |> forget(:room)
    end

    test "delete_message/1 deletes the message" do
      message = insert(:message)
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = insert(:message)
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
