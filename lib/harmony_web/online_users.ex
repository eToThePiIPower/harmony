defmodule HarmonyWeb.OnlineUsers do
  alias HarmonyWeb.Presence

  @topic "online_users"

  def list() do
    @topic
    |> Presence.list()
    |> Enum.into(
      %{},
      fn {user_id, %{metas: connections}} -> {user_id, length(connections)} end
    )
  end

  def track(pid, user) do
    {:ok, _ref} = Presence.track(pid, @topic, user.id, %{})
    :ok
  end

  def online?(online_users, user_id) do
    Map.get(online_users, user_id, 0) > 0
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Harmony.PubSub, @topic)
  end
end
