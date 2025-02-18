defmodule HarmonyWeb.UsersCanCreateRooms do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture() |> set_role(:admin)
    %{conn: log_in_user(conn, user), user: user}
  end

  test "admins can create rooms", %{conn: conn} do
    conn
    |> visit("/")
    |> within("#new-room-modal", fn conn ->
      conn
      |> fill_in("Name", with: "tatooine")
      |> fill_in("Topic", with: "Where it begins")
      |> click_button("Save")
    end)
    |> assert_path("/rooms/tatooine")
    |> assert_has("#room-header .name", text: "tatooine")
    |> assert_has("#room-header .topic", text: "Where it begins")
  end

  test "admins can delete rooms", %{conn: conn} do
    insert(:room, name: "tatooine")

    conn
    |> visit("/rooms/tatooine")
    |> click_link("#room-header #room-delete-link", "Delete")
    |> assert_path("/")
    |> assert_has("#flash-info", text: "Deleted the room #tatooine")
    |> refute_has("#rooms-list .rooms-list-item", text: "tatooine")
  end
end
