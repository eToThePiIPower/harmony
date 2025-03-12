defmodule HarmonyWeb.UsersHaveUnreadMarkersTest do
  use HarmonyWeb.FeatureCase
  import Harmony.Factory

  setup :register_and_log_in_user

  @tag :skip
  # Skipping because PhoenixTest messes up the order on stream(socket, _, _, at: 0)
  test "users see an unread messages marker for new messages", %{conn: conn, user: user} do
    room = insert(:room)
    Harmony.Chat.join_room!(room, user)

    m1 = insert(:message, room: room, body: "Message 1", inserted_at: timeshift(60))
    m2 = insert(:message, room: room, body: "Message 2", inserted_at: timeshift(120))
    Harmony.Chat.update_last_read_id(room, user)
    m3 = insert(:message, room: room, body: "Message 3", inserted_at: timeshift(180))
    m4 = insert(:message, room: room, body: "Message 4", inserted_at: timeshift(240))

    conn
    |> visit("/rooms/#{room.name}")
    # The first two messages, followed by the uneread messages marker
    |> assert_has("#messages-#{m1.id}+#messages-#{m2.id}+#messages-unread-marker", text: "New")
    # The unread messages marker, followed by the final two messages
    |> assert_has("#messages-unread-marker+#messages-#{m3.id}+#messages-#{m4.id}", text: m4.body)

    # after viewing the page, the last read id is updated
    assert Harmony.Chat.get_last_read_id(room, user) == m4.id
  end

  test "there is no marker if the room has just been joined", %{conn: conn, user: user} do
    room = insert(:room)
    Harmony.Chat.join_room!(room, user)

    insert_list(3, :message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> refute_has("#messages-unread-marker", text: "New")
  end

  test "there is no marker if all messages have been read", %{conn: conn, user: user} do
    room = insert(:room)
    Harmony.Chat.join_room!(room, user)

    insert_list(3, :message, room: room)
    Harmony.Chat.update_last_read_id(room, user)

    conn
    |> visit("/rooms/#{room.name}")
    |> refute_has("#messages-unread-marker", text: "New")
  end

  test "there is no marker for visitors", %{conn: conn} do
    room = insert(:room)

    insert_list(3, :message, room: room)

    conn
    |> visit("/rooms/#{room.name}")
    |> refute_has("#messages-unread-marker", text: "New")
  end

  test "the unread messages marker updates on new messages", %{conn: conn, user: user} do
    room = insert(:room)
    Harmony.Chat.join_room!(room, user)

    insert_list(3, :message, room: room)
    Harmony.Chat.update_last_read_id(room, user)

    conn = visit(conn, "/rooms/#{room.name}")
    # The actual exercise - sending a new message
    m4 =
      insert(:message, room: room)
      |> Harmony.Repo.preload(user: :profile, replies: [user: :profile])

    send(conn.view.pid, {:new_message, m4})
    # Need to use the conn again to get it to process the message
    assert_has(conn, ".message-body", text: m4.body)

    assert Harmony.Chat.get_last_read_id(room, user) == m4.id
  end

  defp timeshift(seconds) do
    DateTime.utc_now() |> DateTime.add(seconds, :second)
  end
end
