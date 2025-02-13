defmodule Harmony.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Harmony.Repo

  def room_factory do
    %Harmony.Chat.Room{
      name: sequence(:name, &"room-#{&1}"),
      topic: sequence(:name, &"room-#{&1} is the best room around")
    }
  end
end
