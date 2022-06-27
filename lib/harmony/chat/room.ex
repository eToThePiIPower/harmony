defmodule Harmony.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :description, :string
    field :title, :string
    has_many :messages, Harmony.Chat.Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
    |> unsafe_validate_unique(:title, Harmony.Repo, message: "must be unique")
    |> validate_length(:title, min: 4)
  end
end
