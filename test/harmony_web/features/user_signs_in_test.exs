defmodule HarmonyWeb.UserSignsInTest do
  use HarmonyWeb.FeatureCase, async: true

  test "user can sign in", %{session: session} do
    user = build(:user) |> set_password |> insert

    session
    |> sign_in(as: user)
    |> assert_has(Query.css(".username", text: user.email))
  end
end