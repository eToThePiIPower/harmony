defmodule HarmonyWeb.UsersCanJoinRoomsAsMembersTest do
  use HarmonyWeb.FeatureCase
  import Harmony.Factory

  setup :register_and_log_in_user

  test "users can see a list of available rooms and join them", %{conn: conn} do
    [room1, room2, room3] = insert_list(3, :room)

    conn
    |> visit("/")
    |> refute_has("#rooms-list a", text: room1.name)
    |> refute_has("#rooms-list a", text: room2.name)
    |> refute_has("#rooms-list a", text: room3.name)
    |> assert_has("a", text: "Add a room")
    |> assert_has("#room-index .room-index-item", text: room1.name)
    |> assert_has("#room-index .room-index-item", text: room2.name)
    |> assert_has("#room-index .room-index-item", text: room3.name)
    |> click_button("#room-index #room-index-item-#{room1.id} button", "Join")
    |> assert_has("#rooms-list a", text: room1.name)
    |> refute_has("#rooms-list a", text: room2.name)
    |> refute_has("#rooms-list a", text: room3.name)
  end

  test "the rooms index also shows the joined status", %{conn: conn, user: user} do
    [room1, room2, room3] = insert_list(3, :room)
    Harmony.Chat.join_room!(room1, user)

    conn
    |> visit("/rooms/#{room1.name}")
    |> assert_has("#room-index #room-index-item-#{room1.id}", text: "Joined")
    |> refute_has("#room-index #room-index-item-#{room2.id}", text: "Joined")
    |> refute_has("#room-index #room-index-item-#{room3.id}", text: "Joined")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Join")
    |> assert_has("#room-index #room-index-item-#{room2.id}", text: "Joined")
    |> assert_has("#room-index #room-index-item-#{room2.id} button", text: "Leave")
    |> click_button("#room-index #room-index-item-#{room1.id} button", "Leave")
    |> refute_has("#room-index #room-index-item-#{room1.id}", text: "Joined")
  end

  test "joining a room subscribes to its messages", %{conn: conn} do
    [room1, room2] = insert_pair(:room)

    conn
    |> visit("/rooms/#{room1.name}")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Join")
    |> click_link("#rooms-list .rooms-list-item", room2.name)
    # Fake another user sending a message here
    |> send_message(room2, body: "Hello World 1")
    |> assert_has("#messages-list .message-body", text: "Hello World 1")
  end

  test "multiple joins/rejoins only subscribes once", %{conn: conn, user: user} do
    [room1, room2] = insert_pair(:room)
    Harmony.Chat.join_room!(room1, user)

    conn
    |> visit("/rooms/#{room1.name}")
    # Join/unjoin multiple times
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Join")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Leave")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Join")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Leave")
    |> click_button("#room-index #room-index-item-#{room2.id} button", "Join")
    # Never been in the room, so the unread count doesn't show yet
    |> send_message(room2, body: "Hello World 1")
    |> refute_has("#rooms-list .rooms-list-item .unread-count", count: 1)
    # Go into the room, then back to the first
    |> click_link("#rooms-list .rooms-list-item", room2.name)
    |> click_link("#rooms-list .rooms-list-item", room1.name)
    # Fake another user sending a message here
    |> send_message(room2, body: "Hello World 1")
    |> assert_has("#rooms-list .rooms-list-item .unread-count", text: "1", count: 1)
  end

  defp send_message(conn, room, attrs) do
    attrs = Keyword.merge(attrs, room: room)
    msg = insert(:message, attrs)
    Phoenix.PubSub.broadcast(Harmony.PubSub, topic(room.id), {:new_message, msg})
    conn
  end

  defp topic(room_id), do: "chat_room:#{room_id}"
end
