defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  alias Harmony.Chat

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <.rooms_list_header />
      <.rooms_list title="Rooms">
        <.rooms_list_item :for={room <- @rooms} room={room} active={room.id == @room.id} />
      </.rooms_list>

      <.rooms_list_actions current_user={@current_user} />
    </div>

    <%= if @room do %>
      <div class="flex flex-col grow shadow-lg">
        <.room_header room={@room} hide_topic?={@hide_topic?} />
        <div id="messages-list">
          <.message_item :for={message <- @messages} message={message} />
        </div>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()

    {:ok, assign(socket, rooms: rooms, hide_topic?: false)}
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    room = Chat.get_room(name) || Chat.default_room()
    messages = Chat.list_messages(room)

    {:noreply, assign(socket, room: room, messages: messages, page_title: "##{room.name}")}
  end

  def handle_params(_params, _uri, socket) do
    case Chat.default_room() do
      room = %Chat.Room{} ->
        messages = Chat.list_messages(room)
        {:noreply, assign(socket, room: room, messages: messages, page_title: "##{room.name}")}

      nil ->
        {:noreply, assign(socket, room: nil)}
    end
  end

  def handle_event("toggle-topic", _params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
