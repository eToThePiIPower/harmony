defmodule HarmonyWeb.UsersCanSendRepliessTest do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.Factory
  import Harmony.AccountsFixtures

  alias Harmony.Chat

  setup :register_and_log_in_user

  setup %{conn: conn, user: user} do
    room = insert(:room)
    message = insert(:message, room: room)
    %{conn: conn, user: user, room: room, message: message}
  end

  test "users can send replies to messages", %{
    conn: conn,
    user: user,
    room: room,
    message: message
  } do
    Chat.join_room!(room, user)

    conn
    |> visit("/rooms/#{room.name}")
    |> click_button("#messages-#{message.id} button", "Show replies")
    |> fill_in("#reply-send-form textarea", "Reply Body", with: "Test reply body")
    |> submit()
    |> assert_has("#replies-list .reply-body", text: "Test reply body")
    |> assert_has("#replies-list .reply-user", text: user.username)
  end

  test "users can delete their own replies", %{
    conn: conn,
    user: user,
    room: room,
    message: message
  } do
    Chat.join_room!(room, user)
    reply = insert(:reply, message: message, user: user)

    conn
    |> visit("/rooms/#{room.name}")
    |> click_button("#messages-#{message.id} button", "Show replies")
    |> assert_has("#replies-list .reply-body", text: reply.body)
    |> click_button("#replies-#{reply.id} button", "Delete")
    |> refute_has("#replies-list .reply-body", text: reply.body)
  end

  test "users can see other users replies in real time", %{
    conn: conn,
    room: room,
    message: message
  } do
    user1 = user_fixture()
    user2 = user_fixture()

    session1 =
      conn
      |> log_in_user(user1)
      |> visit("/rooms/#{room.name}")
      |> click_button("#messages-#{message.id} button", "Show replies")

    # in a separate session, user2 also logs in and sends a reply
    session2 =
      conn
      |> log_in_user(user2)
      |> visit("/rooms/#{room.name}")
      |> click_button("#messages-#{message.id} button", "Show replies")
      |> fill_in("#reply-send-form textarea", "Reply Body", with: "Test reply body")
      |> submit()

    # user1 sees the reply pop up
    session1 =
      session1
      |> assert_has("#replies-list .reply-body", text: "Test reply body")
      |> assert_has("#replies-list .reply-user", text: user2.username)

    reply = Chat.list_replies(message.id) |> List.first()

    # user2 deletes their reply
    session2
    |> click_button("#replies-#{reply.id} button", "Delete")

    # user1 sees the reply disappear
    session1
    |> refute_has("#replies-list .reply-body", text: "Test reply body")
  end

  test "replies appear as avatar groups in real time", %{
    conn: conn,
    room: room,
    message: message
  } do
    user1 = user_fixture()
    user2 = user_fixture()

    session1 =
      conn
      |> log_in_user(user1)
      |> visit("/rooms/#{room.name}")
      |> refute_has("#messages-list #messages-#{message.id} .avatar-group")

    # in a separate session, user2 also logs in and sends two replies
    session2 =
      conn
      |> log_in_user(user2)
      |> visit("/rooms/#{room.name}")
      |> click_button("#messages-#{message.id} button", "Show replies")
      |> fill_in("#reply-send-form textarea", "Reply Body", with: "Test reply body")
      |> submit()
      |> fill_in("#reply-send-form textarea", "Reply Body", with: "Test reply body again")
      |> submit()

    [reply1, reply2] = Chat.list_replies(message.id)

    # user1 sees an avatar-group pop up under the message with a count
    session1 =
      session1
      |> assert_has("#messages-list #messages-#{message.id} .avatar-group",
        text: "2 replies from 1 user"
      )

    # user2 deletes a reply
    session2 =
      session2
      |> click_button("#replies-#{reply1.id} button", "Delete")

    # user1 sees the reply count decrement
    session1 =
      session1
      |> assert_has("#messages-list #messages-#{message.id} .avatar-group",
        text: "1 reply from 1 user"
      )

    # user2 deletes their other reply
    session2
    |> click_button("#replies-#{reply2.id} button", "Delete")

    # user1 sees the avatar-group disappear
    session1
    |> refute_has("#messages-list #messages-#{message.id} .avatar-group")
  end
end
