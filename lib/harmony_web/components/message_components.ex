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
            <span class="message-user">{@message.user.email}</span>
          </.link>

          <p class="text-sm message-body">{@message.body}</p>
        </div>
      </div>
    </div>
    """
  end
end
