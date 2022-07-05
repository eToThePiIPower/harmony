defmodule HarmonyWeb.UserSignsUpTest do
  use HarmonyWeb.FeatureCase, async: false

  @tag :noci
  test "user can sign up", %{session: session} do
    session
    |> visit("/users/register")
    |> fill_in(Query.text_field("Email"), with: "new_user@example.com")
    |> fill_in(Query.css("#user_password"), with: "password1234")
    |> fill_in(Query.text_field("Password confirmation"), with: "password1234")
    |> click(Query.button("Register"))
    |> assert_has(Query.css(".username", text: "new_user@example.com"))
  end

  @tag :noci
  test "user must confirm password when they sign up", %{session: session} do
    session
    |> visit("/users/register")
    |> fill_in(Query.text_field("Email"), with: "new_user@example.com")
    |> fill_in(Query.text_field("Password", at: 0, count: 2), with: "password1234")
    |> fill_in(Query.text_field("Password confirmation"), with: "nomatch")
    |> click(Query.button("Register"))
    |> refute_has(Query.css(".username", text: "new_user@example.com"))
    |> assert_has(Query.css(".invalid-feedback", text: "does not match password"))
  end
end
