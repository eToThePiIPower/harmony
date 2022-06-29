defmodule HarmonyWeb.ChatLiveTest do
  use HarmonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Harmony.Factory

  @create_attrs %{title: "hello", description: "This is a new room"}
  @update_attrs %{title: "new-room", description: "This is an updated description"}
  @invalid_attrs %{}

  defp create_room_and_user(_) do
    room = insert(:room)
    user = insert(:user)
    %{room: room, user: user}
  end

  describe "ChatLive :index" do
    setup [:create_room_and_user]

    test "lists all rooms", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, _index_live, html} = live(conn, Routes.chat_path(conn, :index))

      assert html =~ "Select a room"
    end

    test "saves new room", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.chat_path(conn, :index))

      assert index_live |> element("a", "New Room") |> render_click() =~
               "New Room"

      assert_patch(index_live, Routes.chat_path(conn, :new))

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_path(conn, :index))

      assert html =~ "Room created successfully"
    end
  end

  describe "ChatLive :show" do
    setup [:create_room_and_user]

    test "displays room", %{conn: conn, room: room, user: user} do
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, Routes.chat_path(conn, :show, room))

      assert html =~ "#{room.description}"
    end

    test "updates room within modal", %{conn: conn, room: room, user: user} do
      conn = log_in_user(conn, user)
      {:ok, show_live, _html} = live(conn, Routes.chat_path(conn, :show, room))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Room"

      assert_patch(show_live, Routes.chat_path(conn, :edit, room))

      {:ok, _, html} =
        show_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_path(conn, :show, room))

      assert html =~ "Room updated successfully"
    end
  end
end
