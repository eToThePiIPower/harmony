defmodule HarmonyWeb.ChatRoomLiveTest do
  use HarmonyWeb.ConnCase
  import Harmony.Factory
  import Harmony.AccountsFixtures

  setup %{conn: conn} do
    password = valid_user_password()
    user = user_fixture(%{password: password})
    %{conn: log_in_user(conn, user), user: user, password: password}
  end

  test "GET /", %{conn: conn} do
    insert(:room)
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to the chat!"
  end
end
