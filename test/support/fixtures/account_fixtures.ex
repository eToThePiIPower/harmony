defmodule Harmony.AccountFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Harmony.Account` context.
  """

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    password = valid_user_password()
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: password,
      password_confirmation: password
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Harmony.Account.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
