defmodule HarmonyWeb.UserSendsAMessageTest do
  use HarmonyWeb.FeatureCase, async: false

  @tag :noci
  test "user sends a message to a room", %{metadata: metadata} do
    room = insert(:room, description: "Room 1 description")
    [user1, user2] = insert_pair(:user)

    session1 =
      metadata
      |> new_session()
      |> sign_in(as: user1)
      |> join_room(room)

    session2 =
      metadata
      |> new_session()
      |> sign_in(as: user2)
      |> join_room(room)

    session1
    |> add_message("Hi everyone")
    |> assert_has(Query.css(".message-user", text: user1.email))
    |> assert_has(Query.css(".message-body", text: "Hi everyone"))

    session2
    |> assert_has(Query.css(".message-user", text: user1.email))
    |> assert_has(Query.css(".message-body", text: "Hi everyone"))
  end

  @tag :noci
  test "users don't messages from other rooms", %{metadata: metadata} do
    [room1, room2] = insert_pair(:room, description: "Room 1 description")
    [user1, user2] = insert_pair(:user)

    session1 =
      metadata
      |> new_session()
      |> sign_in(as: user1)
      |> join_room(room1)

    session2 =
      metadata
      |> new_session()
      |> sign_in(as: user2)
      |> join_room(room1)
      |> click(Query.link(room2.title))

    session1
    |> add_message("Hi everyone")
    |> assert_has(Query.css(".message-user", text: user1.email))
    |> assert_has(Query.css(".message-body", text: "Hi everyone"))

    session2
    |> refute_has(Query.css(".message-user", text: user1.email))
    |> refute_has(Query.css(".message-body", text: "Hi everyone"))
  end
end
