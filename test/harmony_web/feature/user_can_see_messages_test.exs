defmodule HarmonyWeb.UsersCanSeeMessages do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  alias Harmony.Chat

  setup %{conn: conn} do
    user = user_fixture()
    room = insert(:room)
    Chat.join_room!(room, user)
    %{conn: log_in_user(conn, user), user: user, room: room}
  end

  test "users can see messages when in a room", %{conn: conn, room: room} do
    [m1, m2] = insert_pair(:message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-list .message-body", text: m1.body)
    |> assert_has("#messages-list .message-body", text: m2.body)
    |> assert_has("#messages-list .message-user", text: m1.user.username)
  end

  test "each room has it's own messages", %{conn: conn, room: room, user: user} do
    [m1, m2] = insert_pair(:message, room: room, body: "Show these messages")
    other_room = insert(:room)
    Chat.join_room!(other_room, user)
    [om1, om2] = insert_pair(:message, room: other_room, body: "Not these messages")

    conn
    # The first room has only it's own messages
    |> visit("/rooms/#{room.name}")
    |> assert_has("#messages-#{m1.id}")
    |> assert_has("#messages-#{m2.id}")
    |> refute_has("#messages-#{om1.id}")
    |> refute_has("#messages-#{om2.id}")
    # The other room has only *it's* own messages
    |> click_link(other_room.name)
    |> assert_has("#messages-#{om1.id}")
    |> assert_has("#messages-#{om2.id}")
    |> refute_has("#messages-#{m1.id}")
    |> refute_has("#messages-#{m2.id}")
    # Now back to the first
    |> click_link(room.name)
    |> assert_has("#messages-#{m1.id}")
    |> assert_has("#messages-#{m2.id}")
    |> refute_has("#messages-#{om1.id}")
    |> refute_has("#messages-#{om2.id}")
  end
end
