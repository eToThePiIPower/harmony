defmodule HarmonyWeb.PageController do
  use HarmonyWeb, :controller
  plug :redirect_if_signed_in

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def redirect_if_signed_in(conn, _opts) do
    # I'm using cond here, but you can use the original if
    cond do
      conn.assigns.current_user  -> redirect(conn, to: "/chat") |> halt
      true -> conn
    end
  end
end
