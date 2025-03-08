defmodule HarmonyWeb.Components.RepliesComponent do
  use HarmonyWeb, :live_component

  alias Harmony.Chat
  alias Harmony.Chat.{Message, Reply}

  import HarmonyWeb.ReplyComponents

  def render(assigns) do
    ~H"""
    <div class="relative">
      <div class="drawer drawer-end">
        <input
          id="replies-drawer"
          type="checkbox"
          class="drawer-toggle"
          checked={assigns[:message] != nil}
        />
        <div class="drawer-side z-50">
          <div
            aria-label="close sidebar"
            class="drawer-overlay backdrop-blur-[1px]"
            phx-click="hide-replies"
          >
          </div>
          <div class="menu bg-white w-5/6 md:w-1/3 h-full">
            <div :if={@room} class="header border-b pb-3">
              <h2 class="font-bold">Replies</h2>
              <div>#{@room.name}</div>
            </div>
            <%= if assigns[:message] do %>
              <.message_item message={@message} dom_id="reply-base-message" threaded />
              <hr />
              <div id="replies-list" phx-update="stream">
                <.reply_item
                  :for={{dom_id, reply} <- @streams.replies}
                  dom_id={dom_id}
                  reply={reply}
                  show_delete={@user.id == reply.user_id}
                  delete_target={@myself}
                />
              </div>
              <.send_reply_form form={@form} target={@myself} room={@room} />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(%{new_reply: new_reply, message_id: message_id}, socket) do
    if message_id == socket.assigns.message.id do
      socket
      |> stream_insert(:replies, new_reply)
    else
      socket
    end
    |> ok
  end

  def update(%{deleted_reply: deleted_reply, message_id: message_id}, socket) do
    if message_id == socket.assigns.message.id do
      socket
      |> stream_delete(:replies, deleted_reply)
    else
      socket
    end
    |> ok
  end

  def update(%{message: %Message{} = message} = assigns, socket) do
    replies = message.replies

    changeset = Chat.change_reply(%Reply{})

    socket
    |> assign_reply_form(changeset)
    |> assign(assigns)
    |> stream(:replies, replies, reset: true)
    |> ok
  end

  def update(assigns, socket) do
    changeset = Chat.change_reply(%Reply{})

    socket
    |> assign_reply_form(changeset)
    |> assign(assigns)
    |> ok
  end

  def handle_event("validate-reply", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("send-reply", %{"reply" => reply_params}, socket) do
    user = socket.assigns.user
    message = socket.assigns[:message]

    case Chat.create_reply(user, message, reply_params) do
      {:ok, %Reply{}} ->
        changeset = Chat.change_reply(%Reply{body: ""})

        socket
        |> assign_reply_form(changeset)
        |> noreply

      {:error, changeset} ->
        socket
        |> assign_reply_form(changeset)
        |> noreply
    end
  end

  def handle_event("delete-reply", %{"id" => id}, socket) do
    {:ok, %Chat.Reply{}} = Chat.delete_reply_by_id(id, socket.assigns.user)
    {:noreply, socket}
  end

  defp assign_reply_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
