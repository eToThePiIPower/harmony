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
end
