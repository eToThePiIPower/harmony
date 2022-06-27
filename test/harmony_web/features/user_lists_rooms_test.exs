defmodule HarmonyWeb.UserListsRoomsTest do
  use HarmonyWeb.FeatureCase, async: false

  test "signed in user sees a list of rooms", %{session: session} do
    user = insert(:user)
    room1 = insert(:room, description: "Room 1 description")
    room2 = insert(:room, description: "Room 2 description")

    session
    |> sign_in(as: user)
    |> visit("/chat")
    |> refute_has(Query.text("Room 1 description"))
    |> assert_has(Query.css(".room-list .room-list-item", text: room1.title))
    |> assert_has(Query.css(".room-list .room-list-item", text: room2.title))
    |> click(Query.link(room1.title))
    |> assert_has(Query.css(".description", text: "Room 1 description"))
  end
end
