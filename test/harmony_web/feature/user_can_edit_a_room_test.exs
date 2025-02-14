defmodule HarmonyWeb.UserEditARoomTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory

  test "user can edit a chat room", %{conn: conn} do
    room = insert(:room)

    conn
    |> visit(~p"/rooms/#{room.name}")
    |> click_link("#room-header #room-edit-link", "Edit")
    |> assert_has("header", text: "Edit chat room")
    |> fill_in("Name", with: "new room name")
    |> assert_has("#room-edit-form",
      text: "must contain only lowercase letters, numbers, or dashes"
    )
    |> fill_in("Name", with: "new-room-name")
    |> fill_in("Topic", with: "New topic text")
    |> click_button("Save")
    |> click_link("#rooms-list .rooms-list-item", "new-room-name")
    |> assert_has("#room-header .name", text: "new-room-name")
    |> assert_has("#room-header .topic", text: "New topic text")
  end
end
