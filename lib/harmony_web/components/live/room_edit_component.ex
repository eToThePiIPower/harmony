defmodule HarmonyWeb.Components.RoomEditComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat

  def render(assigns) do
    ~H"""
    <div>
      <.modal id="edit-room-modal">
        <.room_form id="edit-room-form" for={@form} target={@myself} title="Edit chat room" />
      </.modal>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    changeset = Chat.change_room(assigns.room)

    socket
    |> assign(room: assigns.room, current_user: assigns.current_user)
    |> assign_form(changeset)
    |> ok
  end

  def handle_event("validate-room", %{"edit-room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply
  end

  def handle_event("save-room", %{"edit-room" => room_params}, socket) do
    case Chat.update_room(socket.assigns.current_user, socket.assigns.room, room_params) do
      {:ok, room} ->
        socket
        |> put_flash(:info, "##{room.name} has been updated")
        |> push_navigate(to: "/rooms/#{room.name}")
        |> noreply

      {:error, changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "edit-room"))
  end
end
