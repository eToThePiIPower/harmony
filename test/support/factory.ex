defmodule Harmony.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Harmony.Repo

  alias Harmony.Accounts.User
  alias Harmony.Chat.Room

  def room_factory do
    %Harmony.Chat.Room{
      name: sequence(:name, &"room-#{&1}"),
      topic: sequence(:name, &"room-#{&1} is the best room around")
    }
  end

  def with_messages(%Room{} = room, count: count) do
    insert_list(count, :message, room: room)
    room
  end

  def with_messages([%Room{} = room | rest], count: count) do
    insert_list(count, :message, room: room)
    [room | with_messages(rest, count: count)]
  end

  def with_messages([], count: _count) do
    []
  end

  def read_messages(%Room{} = room, %User{} = user) do
    Harmony.Chat.join_room!(room, user)
    Harmony.Chat.update_last_read_id(room, user)
    room
  end

  def read_messages([%Room{} = room | rest], %User{} = user) do
    Harmony.Chat.join_room!(room, user)
    Harmony.Chat.update_last_read_id(room, user)
    [room | read_messages(rest, user)]
  end

  def read_messages([], %User{}) do
    []
  end

  def message_factory do
    %Harmony.Chat.Message{
      body: "Hello",
      user: Harmony.AccountsFixtures.user_fixture(),
      room: build(:room)
    }
  end
end
