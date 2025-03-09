defmodule HarmonyWeb.MessageComponents do
  @moduledoc """
  Provides UI components for Chat.Room.
  """
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  import HarmonyWeb.CoreComponents

  alias Harmony.Chat.Message

  # attr :message, Message OR :unread_marker
  attr :message, :any, required: true
  attr :show_delete, :boolean, default: false
  attr :dom_id, :string
  attr :threaded, :boolean, default: false

  def message_item(%{message: {:date_divider, date}} = assigns) do
    assigns = assign(assigns, :date, date)

    ~H"""
    <div :if={@date != Date.utc_today()} id={@dom_id} class="flex flex-col items-center mt-2">
      <hr class="w-full" />
      <span class="flex items-center justify-center -mt-3 bg-white h-6 px-3 rounded-full border text-xs font-semibold mx-auto">
        {format_date(@date)}
      </span>
    </div>
    """
  end

  def message_item(%{message: :unread_marker} = assigns) do
    ~H"""
    <div id={@dom_id} class="w-full flex text-red-500 items-center gap-3 pr-5">
      <div class="w-full h-px grow bg-red-500"></div>
      <div class="text-sm">New</div>
    </div>
    """
  end

  def message_item(assigns) do
    user = assigns.message.user
    profile = user.profile

    assigns = assign(assigns, profile: profile, user: user)

    ~H"""
    <div id={@dom_id} class="group relative flex px-4 py-3 hover:bg-slate-100">
      <div class="join absolute top-4 right-4 hidden group-hover:inline-flex">
        <.message_delete_button :if={@show_delete} message={@message} />
        <.message_reply_button message={@message} />
      </div>
      <img
        class="h-10 w-10 rounded shrink-0 bg-slate-300"
        style={"background-color: #{avatar_bgcolor(@user.username)};"}
        src={avatar_path(@profile)}
        phx-click={show("#msg-#{@message.id}-profile")}
      />
      <.live_component
        :if={!@threaded}
        module={HarmonyWeb.Components.ProfileComponent}
        id={"msg-#{@message.id}-profile"}
        profile={@profile}
        user={@user}
      />

      <div class="ml-2">
        <div class="-mt-1">
          <.link
            class="text-sm font-semibold hover:underline"
            phx-click={show("#msg-#{@message.id}-profile")}
          >
            <span class="message-user">{@profile.display_name}</span>
          </.link>
          <span
            id={@dom_id <> "timestamp"}
            phx-hook="Timestamp"
            data-timestamp={@message.inserted_at}
            class="ml-1 text-xs text-gray-500"
          >
            {message_timestamp(@message)}
          </span>
          <p class="text-sm message-body">{@message.body}</p>
        </div>

        <.reply_avatar_group :if={@message.replies} replies={@message.replies} />
      </div>
    </div>
    """
  end

  defp format_date(%Date{} = date) do
    today = Date.utc_today()

    case Date.diff(today, date) do
      0 -> "Today"
      1 -> "Yesterday"
      _ -> date |> Calendar.strftime("%A, %d %B %Y")
    end
  end

  attr :message, Message, required: true

  defp message_delete_button(assigns) do
    ~H"""
    <button
      phx-click="delete-message"
      phx-value-id={@message.id}
      data-confirm="Are you sure?"
      class="btn btn-error btn-sm join-item cursor-pointer"
    >
      <.icon name="hero-trash" class="h-4 w-4" />
      <div class="sr-only">Delete</div>
    </button>
    """
  end

  defp message_reply_button(assigns) do
    ~H"""
    <button
      class="btn btn-sm btn-info btn-soft join-item cursor-pointer"
      phx-click="show-replies"
      phx-value-message_id={@message.id}
    >
      <.icon name="hero-arrow-uturn-left" class="h-4 w-4" />
      <div class="sr-only">Show replies</div>
    </button>
    """
  end

  defp avatar_path(profile) do
    if profile.avatar_path do
      profile.avatar_path
    else
      ~p"/images/user_profile.svg"
    end
  end

  defp message_timestamp(message) do
    message.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end

  defp avatar_bgcolor(username) do
    ColorHash.hash(username) |> ColorHash.hsl_to_css()
  end

  attr :replies, :list, default: []

  def reply_avatar_group(assigns) do
    users =
      assigns.replies
      |> Enum.map(& &1.user)
      |> Enum.uniq_by(& &1.id)

    assigns = assign(assigns, :users, users)

    ~H"""
    <div :if={length(@replies) > 0} class="avatar-group -space-x-4">
      <div :for={user <- @users} class="avatar">
        <div class="w-6">
          <img
            src={avatar_path(user.profile)}
            style={"background-color: #{avatar_bgcolor(user.username)};"}
          />
        </div>
      </div>
      <div class="avatar avatar-placeholder">
        <div class="bg-neutral text-neutral-content w-6">
          <span>+{length(@replies)}</span>
          <div class="span sr-only">
            {pluralize_replies_from_users(replies: length(@replies), users: length(@users))}
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp pluralize_replies_from_users(replies: 1, users: 1), do: "1 reply from 1 user"
  defp pluralize_replies_from_users(replies: 1, users: n), do: "1 reply from #{n} users"
  defp pluralize_replies_from_users(replies: n, users: 1), do: "#{n} replies from 1 user"
  defp pluralize_replies_from_users(replies: n, users: m), do: "#{n} replies from #{m} users"
end
