defmodule HarmonyWeb.OnlineUsersTest do
  use Harmony.DataCase, async: true

  alias HarmonyWeb.OnlineUsers

  import Harmony.AccountsFixtures

  describe "list/0" do
    test "is an empty map with nobody tracked" do
      assert OnlineUsers.list() == %{}
    end

    test "returns the count of users" do
      user1 = user_fixture()
      OnlineUsers.track(self(), user1)

      assert OnlineUsers.list() == %{user1.id => 1}
    end
  end

  describe "online?/2" do
    test "returns false if offline" do
      user1 = user_fixture()
      user2 = user_fixture()

      refute OnlineUsers.online?(OnlineUsers.list(), user1.id)
      refute OnlineUsers.online?(OnlineUsers.list(), user2.id)
    end

    test "returns true if online" do
      user1 = user_fixture()
      user2 = user_fixture()
      OnlineUsers.track(self(), user1)

      assert OnlineUsers.online?(OnlineUsers.list(), user1.id)
      refute OnlineUsers.online?(OnlineUsers.list(), user2.id)
    end
  end
end
