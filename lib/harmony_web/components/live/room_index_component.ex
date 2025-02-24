defmodule HarmonyWeb.Components.RoomIndexComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat
  alias HarmonyWeb.Components.RoomNewComponent

  def render(assigns) do
    ~H"""
    <div>
      <.modal id="index-room-modal">
        <.header>
          <span>Browsing rooms</span>
        </.header>
        <div id="room-index" phx-update="stream">
          <div
            :for={{id, {room, joined?}} <- @streams.rooms}
            id={id}
            phx-click={JS.patch("/rooms/#{room.name}")}
            class="room-index-item flex items-center h-10 text-sm pl-8 pr-3 hover:bg-slate-300 group"
          >
            <.icon name="hero-hashtag" />
            <div class="grow">
              <div class="ml-2 leading-none block text-lg">
                {room.name}
              </div>
              <div class="ml-2 leading-none block">
                <span :if={joined?} class="text-green-600 font-bold">Joined</span>
                <span :if={joined?} class="mx-1">·</span>
                <span class="text-gray-600 font-light">{room.topic}</span>
              </div>
            </div>
            <button
              class="hidden group-hover:block rounded-sm hover:bg-zinc-100 py-1 px-2 text-sm font-semibold border border-zinc-400"
              phx-click="toggle-room"
              phx-target={@myself}
              phx-value-room={room.name}
            >
              <%= if joined? do %>
                Leave
              <% else %>
                Join
              <% end %>
            </button>
          </div>
        </div>
        <.link
          :if={@is_admin}
          class="flex items-center block h-10 w-1/2 mx-auto justify-center text-xs text-zinc-900 font-light hover:text-zinc-700 hover:bg-slate-300"
          phx-click={show_modal("new-room-modal")}
        >
          <.icon name="hero-plus" />
          <span class="">Create a new room</span>
        </.link>
      </.modal>

      <.live_component module={RoomNewComponent} id="new-room-component" current_user={@current_user} />
    </div>
    """
  end

  def mount(socket) do
    socket
    |> ok
  end

  def update(assigns, socket) do
    rooms = Chat.list_rooms_with_joined(assigns.current_user)
    is_admin = assigns.current_user.role == :admin

    socket
    |> assign(assigns)
    |> assign(is_admin: is_admin)
    |> stream_configure(:rooms, dom_id: fn {r, _} -> "room-index-item-#{r.id}" end)
    |> stream(:rooms, rooms)
    |> ok
  end

  def handle_event("toggle-room", %{"room" => room_name}, socket) do
    room = Chat.get_room(room_name)
    {room, joined?} = Chat.toggle_room_membership(room, socket.assigns.current_user)
    send(self(), {:toggled_room, room})

    socket
    |> stream_insert(:rooms, {room, joined?})
    |> put_flash(:info, "You have joined ##{room.name}")
    |> noreply
  end
end
