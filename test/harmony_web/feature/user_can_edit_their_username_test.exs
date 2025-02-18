defmodule HarmonyWeb.UserEditTheirUsername do
  use HarmonyWeb.FeatureCase, async: true
  import Harmony.AccountsFixtures

  setup :register_and_log_in_user

  test "user can edit their username", %{conn: conn, user: user} do
    conn
    |> visit(~p"/users/settings")
    |> within("#email_form", fn conn ->
      conn
      |> fill_in("Username", with: "Obiwan")
      |> fill_in("Current password", with: valid_user_password())
      |> click_button("Change Email and Username")
    end)
    |> assert_has("#flash-info", text: "Username updated")

    updated_user = Harmony.Accounts.get_user!(user.id)
    assert updated_user.username == "Obiwan"
  end

  test "changing both doesn't update the database", %{conn: conn, user: user} do
    conn
    |> visit(~p"/users/settings")
    |> within("#email_form", fn conn ->
      conn
      |> fill_in("Email", with: "a-new-email@example.com")
      |> fill_in("Username", with: "Obiwan")
      |> fill_in("Current password", with: valid_user_password())
      |> click_button("Change Email and Username")
    end)
    |> assert_has("#flash-info",
      text: "A link to confirm your email change has been sent to the new address."
    )

    updated_user = Harmony.Accounts.get_user!(user.id)
    assert updated_user.username == user.username
  end
end
