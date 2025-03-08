defmodule HarmonyWeb.ReplyComponents do
  @moduledoc """
  Provides UI components for Chat.Reply items in the RepliesComponent 
  ive component
  """
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  alias Harmony.Chat.Reply

  import HarmonyWeb.CoreComponents

  attr :reply, Reply, required: true
  attr :dom_id, :string
  attr :show_delete, :boolean, default: false
  attr :delete_target, Phoenix.LiveComponent.CID, default: nil

  def reply_item(assigns) do
    ~H"""
    <div id={@dom_id} class="group relative flex px-4 py-3 hover:bg-slate-100">
      <div class="join absolute top-4 right-4 hidden group-hover:inline-flex">
        <.reply_delete_button :if={@show_delete} reply={@reply} target={@delete_target} />
      </div>
      <img
        class="h-10 w-10 rounded shrink-0 bg-slate-300"
        style={"background-color: #{avatar_bgcolor(@reply.user.username)};"}
        src={avatar_path(@reply.user.profile)}
      />
      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span class="reply-user">{@reply.user.username}</span>
          </.link>
          <span
            id={@reply.id <> "timestamp"}
            phx-hook="Timestamp"
            data-timestamp={@reply.inserted_at}
            class="ml-1 text-xs text-gray-500"
          >
            {reply_timestamp(@reply)}
          </span>
          <p class="text-sm reply-body">{@reply.body}</p>
        </div>
      </div>
    </div>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :target, Phoenix.LiveComponent.CID, default: nil
  attr :room, Harmony.Chat.Room, required: true

  def send_reply_form(assigns) do
    ~H"""
    <.form
      for={@form}
      id="reply-send-form"
      phx-submit="send-reply"
      phx-change="validate-reply"
      phx-target={@target}
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
    """
  end

  attr :reply, Reply, required: true
  attr :target, Phoenix.LiveComponent.CID, default: nil

  def reply_delete_button(assigns) do
    ~H"""
    <button
      phx-click="delete-reply"
      phx-value-id={@reply.id}
      phx-target={@target}
      data-confirm="Are you sure?"
      class="btn btn-error btn-sm join-item cursor-pointer"
    >
      <.icon name="hero-trash" class="h-4 w-4" />
      <div class="sr-only">Delete</div>
    </button>
    """
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

  defp reply_timestamp(reply) do
    reply.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end
end
