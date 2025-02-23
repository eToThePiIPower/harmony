defmodule HarmonyWeb.UserComponents do
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  import HarmonyWeb.CoreComponents

  alias Harmony.Accounts.User
  alias HarmonyWeb.OnlineUsers

  attr :user, User, required: true
  attr :online, :boolean, default: false

  def user(assigns) do
    ~H"""
    <div>
      <.link
        class="flex items-center h-8 hover:bg-gray-300 text-sm pl-8 pr-3"
        href="#"
        data-userstatus-for={@user.id}
      >
        <div class="flex justify-center w-4">
          <%= if @online do %>
            <span class="w-2 h-2 rounded-full bg-blue-500" data-online="online"></span>
          <% else %>
            <span class="w-2 h-2 rounded-full border-2 border-gray-500" data-online="offline"></span>
          <% end %>
        </div>

        <span class="ml-2 leading-none">{@user.username}</span>
      </.link>
    </div>
    """
  end

  attr :users, :any, default: []
  attr :online_users, :map, default: %{}

  def users_list(assigns) do
    ~H"""
    <div class="mt-4 grow">
      <div class="flex items-center h-8 px-3">
        <div class="flex items-center grow">
          <span class="ml-2 leading-none font-medium text-sm">Users</span>
        </div>
      </div>

      <div id="users-list">
        <.user :for={user <- @users} user={user} online={OnlineUsers.online?(@online_users, user.id)} />
      </div>
    </div>
    """
  end

  attr :current_user, Harmony.Accounts.User
  slot :inner_block, required: false

  def users_list_actions(assigns) do
    ~H"""
    <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end bg-slate-300 py-2">
      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        {@current_user.username}
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
