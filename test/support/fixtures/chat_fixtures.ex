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

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Harmony.Chat.create_message()

    message
  end
end
