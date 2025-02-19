defmodule HarmonyWeb.UsersCanSeeEachOthersOnlineStatusTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    room = insert(:room)
    %{conn: conn, room: room}
  end

  @tag focus: true
  test "users can see each other's online status", %{conn: conn, room: room} do
    user1 = user_fixture()
    user2 = user_fixture()

    session1 =
      conn
      |> log_in_user(user1)
      |> visit("/rooms/#{room.name}")
      |> assert_user_status(user1.id, "online")
      |> assert_user_status(user2.id, "offline")

    # in a separate browser
    session2 =
      conn
      |> log_in_user(user2)
      |> visit("/rooms/#{room.name}")
      |> assert_user_status(user1.id, "online")
      |> assert_user_status(user2.id, "online")

    # back to the first
    session1
    |> click_link("Log out")

    # and back to the second
    session2
    |> assert_user_status(user1.id, "offline")
    |> assert_user_status(user2.id, "online")
  end

  defp assert_user_status(session, user_id, status) do
    session
    |> assert_has("[data-userstatus-for='#{user_id}'] [data-online='#{status}']")
  end
end
