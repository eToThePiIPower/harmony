defmodule HarmonyWeb.RoomComponents do
  @moduledoc """
  Provides UI components for Chat.Room.
  """
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  import HarmonyWeb.CoreComponents

  alias Harmony.Chat.Room
  # alias Phoenix.LiveView.JS

  attr :active, :boolean, required: true
  attr :room, Room, required: true

  def rooms_list_item(assigns) do
    ~H"""
    <.link
      class={[
        "rooms-list-item flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      patch={~p"/rooms/#{@room.name}"}
    >
      <.icon name="hero-hashtag" class="h-4 w-4" />
      <span class={["ml-2 leading-none name", @active && "font-bold"]}>
        {@room.name}
      </span>
    </.link>
    """
  end

  attr :title, :string, default: "Rooms"
  slot :inner_block, required: true

  def rooms_list(assigns) do
    ~H"""
    <div class="mt-4 overflow-auto">
      <div class="flex items-center h-8 px-3">
        <span class="ml-2 leading-none font-medium text-sm">{@title}</span>
      </div>
      <div id="rooms-list">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :title, :string, default: "Harmony"
  attr :subtitle, :string, default: "Welcome to the chat!"

  def rooms_list_header(assigns) do
    ~H"""
    <div class="flex justify-between items-center shrink-0 h-16 border-b border-slate-300 px-4">
      <div class="flex flex-col gap-1.5">
        <h1 class="text-lg font-bold text-gray-800">
          {@title}
        </h1>
        <span class="self-center text-xs font-dark whitespace-nowrap">
          {@subtitle}
        </span>
      </div>
    </div>
    """
  end

  attr :room, Room, required: true
  attr :hide_topic?, :boolean, default: false

  def room_header(assigns) do
    ~H"""
    <div
      id="room-header"
      phx-click="toggle-topic"
      class="flex justify-between items-center shrink-0 bg-white border-b border-slate-300 px-4 py-4"
    >
      <div class="flex flex-col gap-1.5">
        <h1 class="name text-sm font-bold leading-none">
          #{@room.name}
        </h1>
        <div :if={!@hide_topic?} class="topic text-xs leading-none h-3.5">
          {@room.topic}
        </div>
      </div>
    </div>
    """
  end
end
