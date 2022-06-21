defmodule HarmonyWeb.PageController do
  use HarmonyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
