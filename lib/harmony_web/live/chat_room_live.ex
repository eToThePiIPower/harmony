defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  alias Harmony.{Chat.Room, Repo}

  def render(assigns) do
    ~H"""
    <div class="flex flex-col grow shadow-lg">
      <div
        id="room-header"
        phx-click="toggle-topic"
        class="flex justify-between items-center shrink-0 bg-white border-b border-slate-300 px-4 py-4"
      >
        <div class="flex flex-col gap-1.5">
          <h1 class="name text-sm font-bold leading-none">
            #{@room.name}
          </h1>
          <div class="topic text-xs leading-none h-3.5" :if={!@hide_topic?}>
            {@room.topic}
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    room = Room |> Repo.all() |> List.first()

    {:ok, assign(socket, room: room, hide_topic?: false)}
  end

  def handle_event("toggle-topic", _params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
