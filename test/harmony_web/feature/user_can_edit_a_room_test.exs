defmodule HarmonyWeb.UserEditARoomTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    password = valid_user_password()
    user = user_fixture(%{password: password})
    %{conn: log_in_user(conn, user), user: user, password: password}
  end

  test "admins can edit a chat room", %{conn: conn, user: user} do
    user |> set_role(:admin)
    room = insert(:room)

    conn
    |> visit(~p"/rooms/#{room.name}")
    |> within("#edit-room-form", fn conn ->
      conn
      |> fill_in("Name", with: "new room name")
      |> assert_has("#edit-room-form",
        text: "must contain only lowercase letters, numbers, or dashes"
      )
      |> fill_in("Name", with: "new-room-name")
      |> fill_in("Topic", with: "New topic text")
      |> click_button("Save")
    end)
    |> click_link("#rooms-list .rooms-list-item", "new-room-name")
    |> assert_has("#room-header .name", text: "new-room-name")
    |> assert_has("#room-header .topic", text: "New topic text")
  end
end
