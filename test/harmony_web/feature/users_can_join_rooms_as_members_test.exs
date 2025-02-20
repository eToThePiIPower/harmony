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
    |> assert_has("#room-index a", text: room1.name)
    |> assert_has("#room-index a", text: room2.name)
    |> assert_has("#room-index a", text: room3.name)
    |> click_link("#room-index a", room1.name)
    |> assert_has("#rooms-list a", text: room1.name)
    |> refute_has("#rooms-list a", text: room2.name)
    |> refute_has("#rooms-list a", text: room3.name)
  end
end
