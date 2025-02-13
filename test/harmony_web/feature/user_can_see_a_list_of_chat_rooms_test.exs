defmodule HarmonyWeb.UserCanSeeAListOfChatRoomsTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory

  test "user can see a list of chat rooms", %{conn: conn} do
    room = insert(:room)

    conn
    |> visit("/")
    |> assert_has(".name", text: room.name)
    |> assert_has(".topic", text: room.topic)
  end

  test "user can toggle the room topic visibility", %{conn: conn} do
    room = insert(:room)

    conn
    |> visit("/")
    |> assert_has(".name", text: room.name)
    |> assert_has(".topic", text: room.topic)
    |> click_button("#room-header", room.name)
    |> refute_has(".topic")
    |> click_button("#room-header", room.name)
    |> assert_has(".topic", text: room.topic)
  end
end
