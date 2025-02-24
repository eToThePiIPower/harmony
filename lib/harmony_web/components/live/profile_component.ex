defmodule HarmonyWeb.Components.ProfileComponent do
  use HarmonyWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      data-popover
      id={@id}
      class="hidden absolute top-6 md:top-8 md:left-8 z-10 w-5/6 md:w-3/4 lg:w-1/2 bg-white shadow-xl rounded-xl border"
      phx-click-away={hide("##{@id}")}
    >
      <div class="p-3">
        <div class="flex items-center justify-between mb-2">
          <a href="#">
            <img
              class="w-24 h-24 rounded-xl bg-slate-300 text-center"
              style={"background-color: #{avatar_bgcolor(@user.username)};"}
              src={avatar_path(@profile)}
              alt={@user.username}
            />
          </a>
        </div>
        <p class="text-base font-semibold leading-none text-gray-900">
          <span>{@profile.display_name}</span>
        </p>
        <p class="flex mb-3 text-sm font-normal justify-between">
          <span>@{@user.username}</span>
          <span class="me-2">
            <.tag :if={@user.role == :admin} class="bg-sky-500">
              admin
            </.tag>
            <.tag :if={@user.role == :moderator} class="bg-lime-500">
              moderator
            </.tag>
          </span>
        </p>
        <p class="mb-4 text-sm">
          {@profile.about_me}
        </p>
      </div>
      <div data-popper-arrow></div>
    </div>
    """
  end

  defp avatar_bgcolor(username) do
    ColorHash.hash(username) |> ColorHash.hsl_to_css()
  end

  defp avatar_path(profile) do
    if profile.avatar_path do
      profile.avatar_path
    else
      ~p"/images/user_profile.svg"
    end
  end
end
