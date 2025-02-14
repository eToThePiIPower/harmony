defmodule Harmony.Chat do
  alias Harmony.{Chat.Room, Repo}
  import Ecto.Query

  def list_rooms do
    Repo.all(Room)
  end

  def get_room(name) do
    Repo.get_by(Room, name: name)
  end

  def default_room do
    from(r in Room)
    |> first(:inserted_at)
    |> Repo.one
  end
end
