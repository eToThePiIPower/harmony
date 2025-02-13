defmodule HarmonyWeb.ChatRoomLiveTest do
  use HarmonyWeb.ConnCase
  import Harmony.Factory

  test "GET /", %{conn: conn} do
    insert(:room)
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to the chat!"
  end
end
