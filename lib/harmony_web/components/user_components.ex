defmodule HarmonyWeb.UserComponents do
  use Phoenix.Component
  use Gettext, backend: HarmonyWeb.Gettext
  use HarmonyWeb, :verified_routes

  alias Harmony.Accounts.User

  attr :user, User, required: true
  attr :online, :boolean, default: false

  def user(assigns) do
    ~H"""
    <div>
      <.link class="flex items-center h-8 hover:bg-gray-300 text-sm pl-8 pr-3" href="#">
        <div class="flex justify-center w-4">
          <%= if @online do %>
            <span class="w-2 h-2 rounded-full bg-blue-500"></span>
          <% else %>
            <span class="w-2 h-2 rounded-full border-2 border-gray-500"></span>
          <% end %>
        </div>

        <span class="ml-2 leading-none">{@user.username}</span>
      </.link>
    </div>
    """
  end

  attr :users, :any, default: []

  def users_list(assigns) do
    ~H"""
    <div class="mt-4 grow">
      <div class="flex items-center h-8 px-3">
        <div class="flex items-center grow">
          <span class="ml-2 leading-none font-medium text-sm">Users</span>
        </div>
      </div>

      <div id="users-list">
        <.user :for={user <- @users} user={user} />
      </div>
    </div>
    """
  end
end
