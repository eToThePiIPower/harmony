defmodule HarmonyWeb.ChatLive do
  use HarmonyWeb, :live_view
  alias Harmony.Rooms

  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms()

    {:ok, assign(socket, rooms: rooms)}
  end

  def handle_params(params, _uri, socket) do
    handle_action(socket, socket.assigns.live_action, params)
  end

  defp handle_action(socket, :index, _params) do
     room = %{id: 0}

    {:noreply, assign(socket, room: room)}
  end

  defp handle_action(socket, :show, %{"id" => id}) do
    room = Rooms.get_room!(id)

    {:noreply, assign(socket, room: room)}
  end

  defp handle_action(socket, :new, _params) do
    room = %Rooms.Room{}

    {:noreply, assign(socket, room: room)}
  end

  defp handle_action(socket, :edit, %{"id" => id}) do
    room = Rooms.get_room!(id)

    {:noreply, assign(socket, room: room)}
  end
end
