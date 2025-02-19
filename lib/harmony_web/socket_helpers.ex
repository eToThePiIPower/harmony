defmodule HarmonyWeb.SocketHelpers do
  def ok(%Phoenix.LiveView.Socket{} = socket), do: {:ok, socket}
  def noreply(%Phoenix.LiveView.Socket{} = socket), do: {:noreply, socket}
end
