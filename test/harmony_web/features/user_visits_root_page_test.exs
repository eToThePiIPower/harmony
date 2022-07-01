defmodule HarmonyWeb.UserVisitsRootPageTest do
  use HarmonyWeb.FeatureCase, async: true

  @tag :noci
  test "user can visit root page", %{session: session} do
    session
    |> visit("/")
    |> assert_has(Query.css("h1", text: "Welcome to Harmony!"))
  end
end
