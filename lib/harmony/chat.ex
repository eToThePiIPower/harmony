defmodule Harmony.Chat do
  alias Harmony.{Chat.Room, Repo}
  import Ecto.Query

  def list_rooms do
    from(Room)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def get_room(name) do
    Repo.get_by(Room, name: name)
  end

  def default_room do
    from(Room)
    |> first(:inserted_at)
    |> Repo.one()
  end

  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end
end
