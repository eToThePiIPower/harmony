defmodule HarmonyWeb.UserCanSeeAListOfChatRoomsTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

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

  test "user can switch between rooms", %{conn: conn} do
    [room1, room2] = insert_pair(:room)

    conn
    |> visit("/")
    |> assert_has("#room-header .name", text: room1.name)
    |> assert_has("#room-header .topic", text: room1.topic)
    |> click_link("#rooms-list .rooms-list-item", room2.name)
    |> assert_has("#room-header .name", text: room2.name)
    |> assert_has("#room-header .topic", text: room2.topic)
    |> click_link("#rooms-list .rooms-list-item", room1.name)
    |> assert_has("#room-header .name", text: room1.name)
    |> assert_has("#room-header .topic", text: room1.topic)
  end
end
