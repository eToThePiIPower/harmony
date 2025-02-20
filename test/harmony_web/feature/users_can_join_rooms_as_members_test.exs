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
end
