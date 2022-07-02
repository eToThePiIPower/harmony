defmodule HarmonyWeb.UserSignsInTest do
  use HarmonyWeb.FeatureCase, async: false

  @tag :noci
  test "user can sign in", %{session: session} do
    user = insert(:user)

    session
    |> sign_in(as: user)
    |> assert_has(Query.css(".username", text: user.email))
  end
end
