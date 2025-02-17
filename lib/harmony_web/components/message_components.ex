defmodule HarmonyWeb.MessageComponents do
  @moduledoc """
  Provides UI components for Chat.Room.
  """
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  # import HarmonyWeb.CoreComponents

  alias Harmony.Chat.Message
  # alias Phoenix.LiveView.JS

  attr :message, Message, required: true
  attr :dom_id, :string

  def message_item(assigns) do
    ~H"""
    <div id={@dom_id} class="relative flex px-4 py-3">
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

  defp message_timestamp(message) do
    message.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end
end
