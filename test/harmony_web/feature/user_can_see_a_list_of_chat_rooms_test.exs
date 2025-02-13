defmodule HarmonyWeb.UserCanSeeAListOfChatRoomsTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory

  test "user can see a list of chat rooms", %{conn: conn} do
    [room1, room2] = insert_pair(:room)

    conn
    |> visit("/")
    |> assert_has("#rooms-list .name", text: room1.name)
    |> assert_has("#rooms-list .name", text: room2.name)
  end

  test "user can toggle the room topic visibility", %{conn: conn} do
    room = insert(:room)

    conn
    |> visit("/")
    |> assert_has("#room-header .name", text: room.name)
    |> assert_has("#room-header .topic", text: room.topic)
    |> click_button("#room-header", room.name)
    |> refute_has("#room-header .topic")
    |> click_button("#room-header", room.name)
    |> assert_has("#room-header .topic", text: room.topic)
  end
end
