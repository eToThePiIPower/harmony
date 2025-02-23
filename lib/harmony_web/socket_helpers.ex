defmodule HarmonyWeb.SocketHelpers do
  @type socket() :: Phoenix.LiveView.Socket.t()

  @doc """
  Wraps a socket into a reply tuple of the form {:ok, socket}

  ## Examples
      iex> socket
      iex> |> ok
      {:ok, socket}
  """
  @spec ok(socket()) :: {:ok, socket()}
  def ok(%Phoenix.LiveView.Socket{} = socket), do: {:ok, socket}

  @doc """
  Wraps a socket into a reply tuple of the form {:noreply, socket}

  ## Examples
      iex> socket
      iex> |> noreply
      {:noreply, socket}
  """
  @spec noreply(socket()) :: {:noreply, socket()}
  def noreply(%Phoenix.LiveView.Socket{} = socket), do: {:noreply, socket}
end
