defmodule HarmonyWeb.Components.RoomIndexComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat

  def render(assigns) do
    ~H"""
    <div id="room-index">
      <.modal id="index-room-modal">
        <.header>Browsing rooms</.header>
        <div>
          <.link
            :for={room <- @rooms}
            phx-click="join-room"
            phx-target={@myself}
            phx-value-room={room.name}
            class="flex items-center h-8 text-sm pl-8 pr-3 hover:bg-slate-300"
          >
            <.icon name="hero-hashtag" />
            <span class="ml-2 leading-none">
              {room.name}
            </span>
          </.link>
        </div>
      </.modal>
    </div>
    """
  end

  def mount(socket) do
    rooms = Chat.list_rooms()

    socket
    |> assign(rooms: rooms)
    |> ok
  end

  def handle_event("join-room", %{"room" => room_name}, socket) do
    room = Chat.get_room(room_name)
    Chat.join_room!(room, socket.assigns.current_user)
    send(self(), {:joined_room, room})

    socket
    |> put_flash(:info, "You have joined ##{room.name}")
    |> noreply
  end
end
