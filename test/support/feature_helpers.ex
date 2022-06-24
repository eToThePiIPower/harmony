defmodule HarmonyWeb.FeatureHelpers do
  use Wallaby.DSL

  def sign_in(session, as: user) do
    session
    |> visit("/users/log_in")
    |> fill_in(Query.text_field("Email"), with: user.email)
    |> fill_in(Query.text_field("Password"), with: user.password)
    |> click(Query.button("Log in"))
  end
end
