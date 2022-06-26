defmodule Harmony.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Harmony.Rooms` context.
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
      |> Harmony.Rooms.create_room()

    room
  end
end
