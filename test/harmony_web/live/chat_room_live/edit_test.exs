defmodule HarmonyWeb.ChatRoomLive.EditTest do
  use HarmonyWeb.ConnCase
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    password = valid_user_password()
    user = user_fixture(%{password: password})
    %{conn: log_in_user(conn, user), user: user, password: password}
  end

  test "GET /rooms/:name/edit", %{conn: conn} do
    room = insert(:room)
    conn = get(conn, ~p"/rooms/#{room.name}/edit")
    assert html_response(conn, 200) =~ "Edit chat room"
  end
end
