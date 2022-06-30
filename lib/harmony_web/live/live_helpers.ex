defmodule HarmonyWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.room_index_path(@socket, :index)}>
        <.live_component
          module={HarmonyWeb.ChatLive.FormComponent}
          id={@room.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.chat_path(@socket, :index)}
          room: @room
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div class="modal-backdrop fade show"></div>
    <div id="modal" class="modal fade show" style="display:block;" phx-remove={hide_modal()}>
      <div class="modal-dialog">
        <div
          id="modal-content"
          class="modal-content fade-in-scale"
          phx-click-away={JS.dispatch("click", to: "#close")}
          phx-window-keydown={JS.dispatch("click", to: "#close")}
          phx-key="escape"
        >
          <div class="modal-header">
            <h2 class="h5 modal-title"><%= @title %></h2>
            <%= if @return_to do %>
              <%= live_patch "",
                to: @return_to,
                id: "close",
                class: "btn-close",
                phx_click: hide_modal()
              %>
            <% else %>
              <a id="close" href="#" class="btn-close" phx-click={hide_modal()}></a>
            <% end %>
          </div>

          <div class="modal-body">
            <%= render_slot(@inner_block) %>
          </div>
        </div> <!-- ./modal-content -->
      </div> <!-- ./modal-dialog -->
    </div> <!-- ./modal -->
    """
  end

  def gravatar_for(%Harmony.Account.User{email: email}, size \\ 40) do
    email
    |> String.trim()
    |> String.downcase()
    |> :erlang.md5
    |> Base.encode16(case: :lower)
    |> fn x -> "https://s.gravatar.com/avatar/#{x}?s=#{size}" end.()
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
