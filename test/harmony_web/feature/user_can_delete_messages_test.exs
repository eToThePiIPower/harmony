defmodule HarmonyWeb.UsersCanDeleteMessages do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    room = insert(:room)
    %{conn: log_in_user(conn, user), user: user, room: room}
  end

  test "users can delete their own messages", %{conn: conn, room: room, user: user} do
    [m1, m2] = insert_pair(:message, room: room, user: user)

    conn
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-#{m1.id}")
    |> assert_has("#messages-#{m2.id}")
    |> click_button("#messages-#{m1.id} button", "Delete")
    |> refute_has("#messages-#{m1.id}")
    |> assert_has("#messages-#{m2.id}")
  end

  test "users can't delete others' messages", %{conn: conn, room: room} do
    m = insert(:message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-#{m.id}")
    |> refute_has("#messages-#{m.id} button")
  end
end
