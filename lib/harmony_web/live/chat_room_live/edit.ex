defmodule HarmonyWeb.ChatRoomLive.Edit do
  use HarmonyWeb, :live_view

  alias Harmony.Chat

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-96 mt-12">
      <.header>
        {@page_title}
        <:actions>
          <.link
            class="font-normal text-xs text-blue-600 hover:text-blue-700"
            navigate={~p"/rooms/#{@room.name}"}
          >
            Back
          </.link>
        </:actions>
      </.header>

      <.simple_form for={@form} id="room-edit-form" phx-change="validate-room" phx-submit="save-room">
        <.input field={@form[:name]} type="text" label="Name" phx-debounce />
        <.input field={@form[:topic]} type="text" label="Topic" phx-debounce />

        <:actions>
          <.button phx-disabled-with="Saving..." class="w-full">
            Save
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(%{"name" => name}, _session, socket) do
    room = Chat.get_room(name)

    # {:ok, assign(socket, room: room, page_title: "Edit chat room")}
    changeset = Chat.change_room(room)

    socket =
      socket
      |> assign(page_title: "Edit chat room", room: room)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate-room", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save-room", %{"room" => room_params}, socket) do
    case Chat.update_room(socket.assigns.room, room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "##{room.name} has been updated")
         |> push_navigate(to: ~p"/rooms/#{room.name}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
