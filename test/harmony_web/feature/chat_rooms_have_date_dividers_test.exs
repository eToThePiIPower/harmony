defmodule HarmonyWeb.ChatRoomsHaveDateDividersTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory

  setup :register_and_log_in_user

  test "chat rooms have date diviers", %{conn: conn} do
    room = insert(:room)
    yesterday = yesterday()
    insert(:message, room: room, inserted_at: yesterday)
    insert(:message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-date-divier-#{DateTime.to_date(yesterday)}", text: "Yesterday")
  end

  defp yesterday do
    DateTime.utc_now()
    |> DateTime.add(-1, :day)
  end
end
