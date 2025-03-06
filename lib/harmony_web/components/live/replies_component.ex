defmodule HarmonyWeb.Components.RepliesComponent do
  use HarmonyWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="relative">
      <div class="drawer drawer-end">
        <input
          id="replies-drawer"
          type="checkbox"
          class="drawer-toggle"
          checked={assigns[:message] != nil}
        />
        <div class="drawer-side z-50">
          <div
            aria-label="close sidebar"
            class="drawer-overlay backdrop-blur-[1px]"
            phx-click="hide-replies"
          >
          </div>
          <div class="menu bg-white w-5/6 md:w-1/3 h-full">
            <div :if={@room} class="header border-b pb-3">
              <h2 class="font-bold">Replies</h2>
              <div>#{@room.name}</div>
            </div>
            <%= if assigns[:message] do %>
              <.message_item message={@message} dom_id="reply-base-message" threaded />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
