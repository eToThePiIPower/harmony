defmodule HarmonyWeb.ChatRoomLive do
  use HarmonyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>Welcome to the chat!</div>
    """
  end
end
