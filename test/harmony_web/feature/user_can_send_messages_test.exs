defmodule HarmonyWeb.UsersCanSendMessages do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  alias Harmony.Chat

  setup %{conn: conn} do
    user = user_fixture()
    room = insert(:room)
    %{conn: log_in_user(conn, user), user: user, room: room}
  end

  test "joined users can send messages", %{conn: conn, user: user, room: room} do
    Chat.join_room!(room, user)

    conn
    |> visit("/rooms/#{room.name}")
    |> fill_in("#message-send-form textarea", "Message Body", with: "Test message body")
    |> submit()
    |> assert_has("#messages-list .message-body", text: "Test message body")
    |> assert_has("#messages-list .message-user", text: user.username)
  end

  test "unjoined users cannot send messages", %{conn: conn, room: room} do
    conn
    |> visit("/rooms/#{room.name}")
    |> refute_has("#messages-send-form")
  end
end
