defmodule HarmonyWeb.ChatLive do
  use HarmonyWeb, :live_view
  alias Harmony.Rooms

  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms()

    {:ok, assign(socket, rooms: rooms)}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    room = Rooms.get_room!(id)

    {:noreply, assign(socket, room: room)}
  end

  def handle_params(_params, _uri, socket) do
    room = nil

    {:noreply, assign(socket, room: room)}
  end
end
