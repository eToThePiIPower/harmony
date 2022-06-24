defmodule HarmonyWeb.UserVisitsRootPageTest do
  use HarmonyWeb.FeatureCase, async: true

  test "user can visit root page", %{session: session} do
    session
    |> visit("/")
    |> assert_has(Query.css("h1", text: "Welcome to Harmony!"))
  end

  defp sign_in(session, as: user) do
    session
    |> visit("/users/log_in")
    |> fill_in(Query.text_field("Email"), with: user.email)
    |> fill_in(Query.text_field("Password"), with: user.password)
    |> click(Query.button("Log in"))
    |> assert_has(Query.css(".username", text: user.email))
  end
end
