defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  alias Harmony.Chat
  alias Harmony.Chat.Message

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <.rooms_list_header is_admin={is_admin(@current_user)} />
      <.rooms_list title="Rooms">
        <.rooms_list_item :for={room <- @rooms} room={room} active={room.id == @room.id} />
      </.rooms_list>

      <.rooms_list_actions current_user={@current_user} />
    </div>

    <%= if @room do %>
      <div class="flex flex-col grow shadow-lg">
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
        <.message_send_form form={@send_message_form} room={@room} />
      </div>
    <% end %>

    <%= if @current_user.role == :admin do %>
      <.new_room_modal form={@new_room_form} />
      <%= if @room do %>
        <.edit_room_modal form={@edit_room_form} />
      <% end %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()

    socket =
      socket
      |> assign_room_form(Chat.change_room(%Chat.Room{}, %{}))
      |> assign(rooms: rooms, hide_topic?: false)

    {:ok, socket}
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    if socket.assigns[:room], do: Chat.unsubscribe_from_room(socket.assigns.room)

    room = Chat.get_room(name) || Chat.default_room()
    messages = Chat.list_messages(room)

    changeset = Chat.change_message(%Message{})
    edit_room_changeset = Chat.change_room(room)

    socket =
      socket
      |> assign(room: room, page_title: "##{room.name}")
      |> assign_edit_room_form(edit_room_changeset)
      |> stream(:messages, messages, reset: true)
      |> assign_message_form(changeset)

    Chat.subscribe_to_room(room)

    {:noreply, socket}
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
    socket =
      socket
      |> stream_insert(:messages, message)

    {:noreply, socket}
  end

  def handle_info({:delete_message, message}, socket) do
    socket =
      socket
      |> stream_delete(:messages, message)

    {:noreply, socket}
  end

  def handle_event("toggle-topic", _params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def handle_event("send-message", %{"message" => message_params}, socket) do
    %{current_user: user, room: room} = socket.assigns

    socket =
      case Chat.create_message(user, room, message_params) do
        {:ok, %Chat.Message{}} ->
          socket
          |> assign_message_form(Chat.change_message(%Message{}))

        {:error, changeset} ->
          assign_message_form(socket, changeset)
      end

    {:noreply, socket}
  end

  def handle_event("delete-message", %{"id" => id}, socket) do
    {:ok, %Chat.Message{}} = Chat.delete_message_by_id(id, socket.assigns.current_user)
    {:noreply, socket}
  end

  def handle_event("validate-message", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)

    {:noreply, assign_message_form(socket, changeset)}
  end

  def handle_event("validate-room", %{"new-room" => room_params}, socket) do
    changeset =
      %Chat.Room{}
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_room_form(socket, changeset)}
  end

  def handle_event("validate-room", %{"edit-room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_edit_room_form(socket, changeset)}
  end

  def handle_event("save-room", %{"new-room" => room_params}, socket) do
    case Chat.create_room(socket.assigns.current_user, room_params) do
      {:ok, room} ->
        socket =
          socket
          |> put_flash(:info, "Created a room")
          |> push_navigate(to: ~p"/rooms/#{room.name}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_room_form(socket, changeset)}
    end
  end

  def handle_event("save-room", %{"edit-room" => room_params}, socket) do
    case Chat.update_room(socket.assigns.current_user, socket.assigns.room, room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "##{room.name} has been updated")
         |> push_navigate(to: ~p"/rooms/#{room.name}")}

      {:error, changeset} ->
        {:noreply, assign_edit_room_form(socket, changeset)}
    end
  end

  def handle_event("delete-room", %{"room_id" => id}, socket) do
    {:ok, room} = Chat.delete_room_by_id(socket.assigns.current_user, id)

    socket =
      socket
      |> put_flash(:info, "Deleted the room ##{room.name}")
      |> push_navigate(to: ~p"/")

    {:noreply, socket}
  end

  defp assign_room_form(socket, changeset) do
    assign(socket, :new_room_form, to_form(changeset, as: "new-room"))
  end

  defp assign_edit_room_form(socket, changeset) do
    assign(socket, :edit_room_form, to_form(changeset, as: "edit-room"))
  end

  defp assign_message_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :send_message_form, to_form(changeset))
  end

  defp is_admin(%Harmony.Accounts.User{role: role}) do
    role == :admin
  end
end
