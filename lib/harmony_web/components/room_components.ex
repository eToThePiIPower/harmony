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

  attr :form, Ecto.Form
  attr :room, Room

  def message_send_form(assigns) do
    ~H"""
    <div class="h-12 bg-white px-4 pb-4">
      <.form
        for={@form}
        id="message-send-form"
        phx-submit="send-message"
        phx-change="validate-message"
        class="flex items-center border-2 border-slate-300 rounded-sm p-1"
      >
        <label for="chat-message-textarea" class="sr-only">Message Body</label>
        <textarea
          class="grow text-sm px-3 border-l border-slate-300 mx-1 resize-none"
          cols=""
          id="chat-message-textarea"
          name={@form[:body].name}
          placeholder={"Message ##{@room.name}"}
          phx-hook="CtrlEnterSubmit"
          phx-debounce
          rows="1"
        >{Phoenix.HTML.Form.normalize_value("textarea", @form[:body].value)}</textarea>
        <button class="shrink flex items-center justify-center h-6 w-6 rounded hover:bg-slate-200">
          <.icon name="hero-paper-airplane" class="h-4 w-4" />
        </button>
      </.form>
    </div>
    """
  end

  attr :title, :string, default: "Rooms"
  slot :inner_block, required: true

  def rooms_list(assigns) do
    ~H"""
    <div class="mt-4 overflow-auto flex-grow">
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
          <.link
            id="room-edit-link"
            class="font-normal text-xs text-blue-600 hover:text-blue-700"
            navigate={~p"/rooms/#{@room.name}/edit"}
          >
            Edit
          </.link>
        </h1>
        <div :if={!@hide_topic?} class="topic text-xs leading-none h-3.5">
          {@room.topic}
        </div>
      </div>
    </div>
    """
  end

  attr :current_user, Harmony.Accounts.User
  slot :inner_block, required: false

  def rooms_list_actions(assigns) do
    ~H"""
    <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end bg-slate-300 py-2">
      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        {@current_user.email}
      </li>

      <li>
        <.link
          href={~p"/users/settings"}
          title="Settings"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          <.icon name="hero-user-circle" />
          <div class="sr-only">Settings</div>
        </.link>
      </li>

      <li>
        <.link
          href={~p"/users/log_out"}
          method="delete"
          title="Log out"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          <.icon name="hero-arrow-right-start-on-rectangle" />
          <div class="sr-only">Log out</div>
        </.link>
      </li>
    </ul>
    """
  end
end
