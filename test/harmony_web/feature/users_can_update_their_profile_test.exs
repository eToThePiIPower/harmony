defmodule HarmonyWeb.UsersCanUpdateTheirProfilesTest do
  use HarmonyWeb.FeatureCase
  alias Harmony.Accounts

  setup :register_and_log_in_user

  test "users can upload an avatar", %{conn: conn, user: user} do
    conn
    |> visit(~p"/users/settings")
    |> upload("Avatar", "test/support/avatar.png")
    |> assert_has("img#avatar-preview")
    |> click_button("Update profile")

    assert File.exists?("priv/static/uploads/#{user.id}")
  end

  test "user can update about_me and display_name", %{conn: conn, user: user} do
    conn
    |> visit(~p"/users/settings")
    |> within("#profile_form", fn conn ->
      conn
      |> fill_in("Display Name", with: "I am awesome")
      |> fill_in("About me", with: "This is my bio")
      |> upload("Avatar", "test/support/avatar.png")
      |> assert_has("img#avatar-preview")
      |> click_button("Update profile")
    end)

    profile = Accounts.get_user_profile(user)
    assert profile.display_name == "I am awesome"
    assert profile.about_me == "This is my bio"
    assert profile.avatar_path == "/uploads/#{user.id}"
  end
end
