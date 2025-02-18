defmodule HarmonyWeb.UsersCanCreateRooms do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture() |> set_role(:admin)
    %{conn: log_in_user(conn, user), user: user}
  end

  test "users can create rooms", %{conn: conn} do
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
end
