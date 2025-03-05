defmodule HarmonyWeb.Components.RoomIndexComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat
  alias HarmonyWeb.Components.RoomNewComponent

  def render(assigns) do
    ~H"""
    <div>
      <.modal id="room-index-modal">
        <.header>
          <span>Browsing rooms</span>
        </.header>
        <ul id="room-index" phx-update="stream" class="list">
          <li
            :for={{id, {room, joined?}} <- @streams.rooms}
            id={id}
            phx-click={JS.patch("/rooms/#{room.name}")}
            class="room-index-item list-row p-2 group"
          >
            <.icon name="hero-hashtag" />
            <div class="list-col-grow">
              <div class="block text-lg">
                {room.name}
              </div>
              <div class="block">
                <span :if={joined?} class="text-success font-bold">Joined</span>
                <span :if={joined?} class="mx-1">·</span>
                <span class="text-gray-600 font-light">{room.topic}</span>
              </div>
            </div>
            <div class="list-col w-24 h-8">
              <button
                class="btn btn-ghost hidden group-hover:block"
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
          </li>
        </ul>
        <.link
          :if={@is_admin}
          class="btn btn-block btn-ghost my-2"
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
