defmodule HarmonyWeb.ChatLive do
  use HarmonyWeb, :live_view
  alias Harmony.Chat
  alias HarmonyWeb.ChatLive.{FormComponent,ListComponent,ShowComponent}
  alias Harmony.Account

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    rooms = Chat.list_rooms()
    user = Account.get_user_by_session_token(user_token)
    {:ok, assign(socket, rooms: rooms, current_user: user)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    handle_action(socket, socket.assigns.live_action, params)
  end

  defp handle_action(socket, :index, _params) do
     room = %{id: 0}
    {:noreply, assign(socket, room: room)}
  end

  defp handle_action(socket, :show, %{"id" => id}) do
    room = Chat.get_room!(id) |> Chat.preload_room_messages
    Phoenix.PubSub.subscribe(Harmony.PubSub, "room-channel-#{room.title}")
    {:noreply, assign(socket, room: room, messages: room.messages)}
  end

  defp handle_action(socket, :new, _params) do
    room = %Chat.Room{}
    {:noreply,
     socket
     |> assign(room: room)
     |> assign(modal_title: "Add a Room")
     |> assign(return_to: Routes.chat_path(socket, :index))
    }
  end

  defp handle_action(socket, :edit, %{"id" => id}) do
    room = Chat.get_room!(id) |> Chat.preload_room_messages
    {:noreply,
     socket
     |> assign(room: room)
     |> assign(messages: room.messages)
     |> assign(modal_title: "Edit Room")
     |> assign(return_to: Routes.chat_path(socket, :show, room))
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Chat.get_room!(id)
    {:ok, _} = Chat.delete_room(room)
    {:noreply,
     socket
     |> push_redirect(to: Routes.chat_path(socket, :index))
     |> put_flash(:success, "Deleted room")
     |> assign(:rooms, Chat.list_rooms())}
  end

  @impl true
  def handle_event("send-message", %{"body" => body}, socket) do
    user = socket.assigns.current_user
    room = socket.assigns.room
    message = Chat.create_message(%{body: body, room_id: room.id, user_id: user.id})
    Phoenix.PubSub.broadcast(Harmony.PubSub, "room-channel-#{room.title}", {:new_message, %{message: message}})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, %{message: message}}, socket) do
    {:noreply,
     socket
     |> assign(:messages, [message])
    }
    # {:noreply, socket}
  end
end
