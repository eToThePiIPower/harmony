defmodule HarmonyWeb.UsersCanSeeMessages do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    room = insert(:room)
    %{conn: log_in_user(conn, user), user: user, room: room}
  end

  test "users can see messages when in a room", %{conn: conn, room: room} do
    [m1, m2] = insert_pair(:message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-list .message-body", text: m1.body)
    |> assert_has("#messages-list .message-body", text: m2.body)
    |> assert_has("#messages-list .message-user", text: m1.user.email)
  end
end
