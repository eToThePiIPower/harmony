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
              <hr />
              <div
                :for={reply <- @message.replies}
                class="group relative flex px-4 py-3 hover:bg-slate-100"
              >
                <img
                  class="h-10 w-10 rounded shrink-0 bg-slate-300"
                  style={"background-color: #{avatar_bgcolor(reply.user.username)};"}
                  src={avatar_path(reply.user.profile)}
                />
                <div class="ml-2">
                  <div class="-mt-1">
                    <.link class="text-sm font-semibold hover:underline">
                      <span class="message-user">{reply.user.username}</span>
                    </.link>
                    <span
                      id={reply.id <> "timestamp"}
                      phx-hook="Timestamp"
                      data-timestamp={reply.inserted_at}
                      class="ml-1 text-xs text-gray-500"
                    >
                      {message_timestamp(reply)}
                    </span>
                    <p class="text-sm message-body">{reply.body}</p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp message_timestamp(message) do
    message.inserted_at |> Calendar.strftime("%I:%M %p on %Y/%m/%d")
  end

  defp avatar_path(profile) do
    if profile.avatar_path do
      profile.avatar_path
    else
      ~p"/images/user_profile.svg"
    end
  end

  defp avatar_bgcolor(username) do
    ColorHash.hash(username) |> ColorHash.hsl_to_css()
  end
end
