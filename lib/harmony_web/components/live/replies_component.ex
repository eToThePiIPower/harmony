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
                <div
                  :for={{dom_id, reply} <- @streams.replies}
                  id={dom_id}
                  class="group relative flex px-4 py-3 hover:bg-slate-100"
                >
                  <div class="join absolute top-4 right-4 hidden group-hover:inline-flex">
                    <.reply_delete_button
                      :if={@user.id == reply.user_id}
                      reply={reply}
                      target={@myself}
                    />
                  </div>
                  <img
                    class="h-10 w-10 rounded shrink-0 bg-slate-300"
                    style={"background-color: #{avatar_bgcolor(reply.user.username)};"}
                    src={avatar_path(reply.user.profile)}
                  />
                  <div class="ml-2">
                    <div class="-mt-1">
                      <.link class="text-sm font-semibold hover:underline">
                        <span class="reply-user">{reply.user.username}</span>
                      </.link>
                      <span
                        id={reply.id <> "timestamp"}
                        phx-hook="Timestamp"
                        data-timestamp={reply.inserted_at}
                        class="ml-1 text-xs text-gray-500"
                      >
                        {message_timestamp(reply)}
                      </span>
                      <p class="text-sm reply-body">{reply.body}</p>
                    </div>
                  </div>
                </div>
              </div>
              <.form
                for={@form}
                id="reply-send-form"
                phx-submit="send-reply"
                phx-change="validate-reply"
                phx-target={@myself}
                class="p-2 join"
              >
                <label for="chat-reply-textarea" class="sr-only">Reply Body</label>
                <textarea
                  class="textarea textarea-primary textarea-md join-item grow"
                  id="chat-reply-textarea"
                  name={@form[:body].name}
                  placeholder={"Reply in ##{@room.name}"}
                  phx-hook="CtrlEnterSubmit"
                  phx-debounce
                  rows="3"
                >{Phoenix.HTML.Form.normalize_value("textarea", @form[:body].value)}</textarea>
                <button class="btn btn-primary join-item h-full">
                  <.icon name="hero-paper-airplane" class="h-4 w-4" />
                </button>
              </.form>
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

  defp message_timestamp(message) do
    message.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end

  defp avatar_path(profile) do
    if profile.avatar_path do
      profile.avatar_path
    else
      ~p"/images/user_profile.svg"
    end
  end

  defp avatar_bgcolor(username) do
    ColorHash.hash(username) |> ColorHash.hsl_to_css()
  end
end
