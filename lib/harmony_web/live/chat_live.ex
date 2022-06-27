defmodule HarmonyWeb.ChatLive do
  use HarmonyWeb, :live_view
  alias Harmony.Chat
  alias HarmonyWeb.ChatLive.{FormComponent,ListComponent,ShowComponent}

  @impl true
  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()
    {:ok, assign(socket, rooms: rooms)}
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
    room = Chat.get_room!(id)
    {:noreply, assign(socket, room: room)}
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
    room = Chat.get_room!(id)
    {:noreply,
     socket
     |> assign(room: room)
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
end
