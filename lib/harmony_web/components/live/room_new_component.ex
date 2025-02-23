defmodule HarmonyWeb.Components.RoomNewComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat

  def render(assigns) do
    ~H"""
    <div>
      <.modal id="new-room-modal">
        <.room_form id="new-room-form" for={@form} target={@myself} title="New chat room" />
      </.modal>
    </div>
    """
  end

  def mount(socket) do
    changeset = Chat.change_room(%Chat.Room{})

    socket
    |> assign_form(changeset)
    |> ok
  end

  def handle_event("validate-room", %{"new-room" => room_params}, socket) do
    changeset =
      %Chat.Room{}
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply
  end

  def handle_event("save-room", %{"new-room" => room_params}, socket) do
    case Chat.create_room(socket.assigns.current_user, room_params) do
      {:ok, room} ->
        socket
        |> put_flash(:info, "Created a room")
        |> push_navigate(to: ~p"/rooms/#{room.name}")
        |> noreply

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "new-room"))
  end
end
