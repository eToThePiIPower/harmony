defmodule Harmony.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Harmony.Chat` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Harmony.Chat.create_room()

    room
  end
end
