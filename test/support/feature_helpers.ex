defmodule HarmonyWeb.FeatureHelpers do
  use Wallaby.DSL

  def sign_in(session, as: user) do
    session
    |> visit("/users/log_in")
    |> fill_in(Query.text_field("Email"), with: user.email)
    |> fill_in(Query.text_field("Password"), with: user.password)
    |> click(Query.button("Log in"))
  end

  def new_session(metadata) do
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    session
  end

  def join_room(session, room) do
    session
    |> visit("/chat")
    |> click(Query.link(room.title))
  end

  def add_message(session, message) do
    session
    |> fill_in(Query.css("textarea"), with: message)
    |> click(Query.button("Send"))
  end
end
