defmodule HarmonyWeb.MessageComponents do
  @moduledoc """
  Provides UI components for Chat.Room.
  """
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  import HarmonyWeb.CoreComponents

  alias Harmony.Chat.Message
  # alias Phoenix.LiveView.JS

  # attr :message, Message OR :unread_marker
  attr :message, :any, required: true
  attr :show_delete, :boolean, default: false
  attr :dom_id, :string

  def message_item(%{message: :unread_marker} = assigns) do
    ~H"""
    <div id={@dom_id} class="w-full flex text-red-500 items-center gap-3 pr-5">
      <div class="w-full h-px grow bg-red-500"></div>
      <div class="text-sm">New</div>
    </div>
    """
  end

  def message_item(assigns) do
    ~H"""
    <div id={@dom_id} class="group relative flex px-4 py-3 hover:bg-slate-100">
      <.message_delete_button :if={@show_delete} message={@message} />
      <div class="h-10 w-10 rounded shrink-0 bg-slate-300"></div>

      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span class="message-user">{@message.user.username}</span>
          </.link>
          <span
            id={@dom_id <> "timestamp"}
            phx-hook="Timestamp"
            data-timestamp={@message.inserted_at}
            class="ml-1 text-xs text-gray-500"
          >
            {message_timestamp(@message)}
          </span>
          <p class="text-sm message-body">{@message.body}</p>
        </div>
      </div>
    </div>
    """
  end

  attr :message, Message, required: true

  defp message_delete_button(assigns) do
    ~H"""
    <button
      phx-click="delete-message"
      phx-value-id={@message.id}
      data-confirm="Are you sure?"
      class="absolute top-4 right-4 text-red-500 hover:text-red-800 cursor-pointer hidden group-hover:block"
    >
      <.icon name="hero-trash" class="h-4 w-4" />
      <div class="sr-only">Delete</div>
    </button>
    """
  end

  defp message_timestamp(message) do
    message.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end
end
