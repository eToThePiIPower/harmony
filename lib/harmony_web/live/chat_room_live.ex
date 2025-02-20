defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  alias Harmony.Accounts
  alias Harmony.Chat
  alias Harmony.Chat.Message
  alias HarmonyWeb.Components.{RoomEditComponent, RoomIndexComponent, RoomNewComponent}
  alias HarmonyWeb.OnlineUsers

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <.rooms_list_header is_admin={is_admin(@current_user)} />
      <.rooms_list title="Rooms">
        <.rooms_list_item :for={room <- @rooms} room={room} active={room.id == @room.id} />
        <.rooms_list_xitem on_click={show_modal("index-room-modal")} icon="plus" title="Add a room" />
      </.rooms_list>
    </div>

    <div class="flex flex-col grow shadow-lg">
      <%= if @room do %>
        <.room_header is_admin={is_admin(@current_user)} room={@room} hide_topic?={@hide_topic?} />
        <div
          id="messages-list"
          class="overflow-auto flex-grow"
          phx-update="stream"
          phx-hook="MessagesList"
        >
          <.message_item
            :for={{dom_id, message} <- @streams.messages}
            dom_id={dom_id}
            message={message}
            show_delete={@current_user == message.user}
          />
        </div>
        <.message_send_form
          :if={Chat.joined?(@room, @current_user)}
          form={@send_message_form}
          room={@room}
        />
      <% end %>
    </div>

    <div class="flex flex-col shrink-0 w-64 bg-slate-100 push-right">
      <.users_list users={@users} online_users={@online_users} />

      <.users_list_actions current_user={@current_user} />
    </div>

    <%= if @current_user.role == :admin do %>
      <!-- Room modals -->
      <.live_component module={RoomNewComponent} id="new-room-component" current_user={@current_user} />
      <%= if @room do %>
        <.live_component
          module={RoomEditComponent}
          id="edit-room-component"
          room={@room}
          current_user={@current_user}
        />
      <% end %>
    <% end %>
    <.live_component
      module={RoomIndexComponent}
      id="room-index-component"
      current_user={@current_user}
    />
    """
  end

  def mount(_params, _session, socket) do
    # rooms = Chat.list_rooms()
    rooms = Chat.list_joined_rooms(socket.assigns.current_user)
    users = Accounts.list_users()

    if connected?(socket) do
      OnlineUsers.track(self(), socket.assigns.current_user)
    end

    OnlineUsers.subscribe()

    socket
    |> assign(online_users: OnlineUsers.list())
    |> assign(rooms: rooms, hide_topic?: false)
    |> assign(users: users)
    |> ok
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    if socket.assigns[:room], do: Chat.unsubscribe_from_room(socket.assigns.room)
    room = Chat.get_room(name) || Chat.default_room()
    Chat.subscribe_to_room(room)
    messages = Chat.list_messages(room)

    message_changeset = Chat.change_message(%Message{})

    socket
    |> assign(room: room, page_title: "##{room.name}")
    |> stream(:messages, messages, reset: true)
    |> assign_message_form(message_changeset)
    |> noreply()
  end

  def handle_params(_params, uri, socket) do
    case Chat.default_room() do
      %{name: name} = %Chat.Room{} ->
        handle_params(%{"name" => name}, uri, socket)

      nil ->
        {:noreply, assign(socket, room: nil)}
    end
  end

  def handle_info({:new_message, message}, socket) do
    socket
    |> stream_insert(:messages, message)
    |> noreply()
  end

  def handle_info({:delete_message, message}, socket) do
    socket
    |> stream_delete(:messages, message)
    |> noreply
  end

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    online_users = OnlineUsers.list()

    socket
    |> assign(online_users: online_users)
    |> noreply
  end

  def handle_info({:joined_room, %Chat.Room{}}, socket) do
    socket
    |> assign(:rooms, Chat.list_joined_rooms(socket.assigns.current_user))
    |> noreply
  end

  def handle_event("toggle-topic", _params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def handle_event("send-message", %{"message" => message_params}, socket) do
    %{current_user: user, room: room} = socket.assigns

    case Chat.create_message(user, room, message_params) do
      {:ok, %Chat.Message{}} ->
        socket
        |> assign_message_form(Chat.change_message(%Message{}))

      {:error, :unauthorized} ->
        socket
        |> put_flash(:error, "You are not authorized to send messages here")

      {:error, changeset} ->
        socket
        |> assign_message_form(changeset)
    end
    |> noreply
  end

  def handle_event("delete-message", %{"id" => id}, socket) do
    {:ok, %Chat.Message{}} = Chat.delete_message_by_id(id, socket.assigns.current_user)
    {:noreply, socket}
  end

  def handle_event("validate-message", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)

    {:noreply, assign_message_form(socket, changeset)}
  end

  def handle_event("delete-room", %{"room_id" => id}, socket) do
    {:ok, room} = Chat.delete_room_by_id(socket.assigns.current_user, id)

    socket
    |> put_flash(:info, "Deleted the room ##{room.name}")
    |> push_navigate(to: ~p"/")
    |> noreply
  end

  defp assign_message_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :send_message_form, to_form(changeset))
  end

  defp is_admin(%Harmony.Accounts.User{role: role}) do
    role == :admin
  end
end
