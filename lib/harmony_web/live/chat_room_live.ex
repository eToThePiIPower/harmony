defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  alias Harmony.{Chat.Room, Repo}

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <.rooms_list_header />
      <.rooms_list title="Rooms">
        <.rooms_list_item :for={room <- @rooms} room={room} active={room.id == @room.id} />
      </.rooms_list>
    </div>

    <div class="flex flex-col grow shadow-lg">
      <.room_header room={@room} hide_topic?={@hide_topic?}/>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    rooms = Room |> Repo.all()
    room = rooms |> List.first()

    {:ok, assign(socket, room: room, rooms: rooms, hide_topic?: false)}
  end

  def handle_event("toggle-topic", _params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
