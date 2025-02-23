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
        <.rooms_list_item
          :for={{room, unread, _all_new?} <- @rooms}
          room={room}
          unread={unread}
          active={room.id == @room.id}
        />
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
            show_delete={is_struct(message) && @current_user == message.user}
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
    rooms = Chat.list_joined_rooms_with_unread_counts(socket.assigns.current_user)
    users = Accounts.list_users()

    if connected?(socket) do
      OnlineUsers.track(self(), socket.assigns.current_user)
    end

    OnlineUsers.subscribe()
    Enum.each(rooms, fn {room, _, _} -> Chat.subscribe_to_room(room) end)

    socket
    |> assign(online_users: OnlineUsers.list())
    |> assign(rooms: rooms, hide_topic?: false)
    |> assign(users: users)
    |> stream_configure(:messages,
      dom_id: fn
        %Chat.Message{id: id} -> "messages-#{id}"
        :unread_marker -> "messages-unread-marker"
      end
    )
    |> ok
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    room = Chat.get_room(name) || Chat.default_room()

    # socket.assigns[:room] is still the old room (or nil)
    maybe_update_visitor_subscriptions(socket.assigns[:room], room, socket.assigns.current_user)

    last_read_id = Chat.get_last_read_id(room, socket.assigns.current_user)

    messages =
      room
      |> Chat.list_messages()
      |> maybe_insert_unread_marker(last_read_id)

    Chat.update_last_read_id(room, socket.assigns.current_user)

    message_changeset = Chat.change_message(%Message{})

    socket
    |> assign(room: room, page_title: "##{room.name}")
    |> update(:rooms, reset_current_rooms_unread(room))
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
    cond do
      message.room_id == socket.assigns.room.id ->
        Chat.update_last_read_id(socket.assigns.room, socket.assigns.current_user)

        socket
        |> stream_insert(:messages, message)

      message.user_id != socket.assigns.current_user.id ->
        socket
        |> update(:rooms, inc_other_rooms_unread(message.room))

      true ->
        socket
    end
    |> noreply
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

  def handle_info({:toggled_room, %Chat.Room{} = room}, socket) do
    if Chat.joined?(room, socket.assigns.current_user) do
      Chat.subscribe_to_room(room)
    else
      Chat.unsubscribe_from_room(room)
    end

    socket
    |> assign(:rooms, Chat.list_joined_rooms_with_unread_counts(socket.assigns.current_user))
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

  defp inc_other_rooms_unread(room) do
    id = room.id

    fn rooms ->
      Enum.map(rooms, fn
        {%Chat.Room{id: ^id} = room, count, false} -> {room, count + 1, false}
        other -> other
      end)
    end
  end

  defp reset_current_rooms_unread(room) do
    id = room.id

    fn rooms ->
      Enum.map(rooms, fn
        {%Chat.Room{id: ^id} = room, _, _} -> {room, 0, false}
        other -> other
      end)
    end
  end

  defp assign_message_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :send_message_form, to_form(changeset))
  end

  defp is_admin(%Harmony.Accounts.User{role: role}) do
    role == :admin
  end

  defp maybe_insert_unread_marker(messages, nil), do: messages

  defp maybe_insert_unread_marker(messages, id) do
    case Enum.split_while(messages, &(&1.id <= id)) do
      {read, []} -> read
      # {read, unread} -> read ++ [:unread_marker | unread]
      {read, unread} -> read ++ [:unread_marker | unread]
    end
  end

  defp maybe_update_visitor_subscriptions(old_room, new_room, user) do
    if old_room && !Chat.joined?(old_room, user) do
      Chat.unsubscribe_from_room(old_room)
    end

    if new_room && !Chat.joined?(new_room, user) do
      Chat.subscribe_to_room(new_room)
    end
  end
end
