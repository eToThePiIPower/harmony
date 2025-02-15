defmodule Harmony.Chat.MessageTest do
  use Harmony.DataCase, async: true
  alias Harmony.Chat.Message
  import Harmony.Factory

  describe "Chat.Message:body" do
    test "validates existence" do
      message = build(:message)

      changeset = Message.changeset(message, %{body: ""})
      refute changeset.valid?

      changeset = Message.changeset(message, %{body: nil})
      refute changeset.valid?
    end
  end
end
