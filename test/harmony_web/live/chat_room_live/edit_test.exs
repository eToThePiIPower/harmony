defmodule HarmonyWeb.ChatRoomLive.EditTest do
  use HarmonyWeb.ConnCase
  import Harmony.Factory

  test "GET /rooms/:name/edit", %{conn: conn} do
    room = insert(:room)
    conn = get(conn, ~p"/rooms/#{room.name}/edit")
    assert html_response(conn, 200) =~ "Edit chat room"
  end
end
