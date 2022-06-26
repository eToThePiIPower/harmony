defmodule Harmony.Factory do
  use ExMachina.Ecto, repo: Harmony.Repo

  def user_factory do
    %Harmony.Account.User{
      email: sequence(:email, &"user#{&1}@example.com"),
      password: "password"
    }
  end

  def set_password(%{password: password} = user) do
    hashed_password = Bcrypt.hash_pwd_salt(password)
    %{user | hashed_password: hashed_password}
  end

  def set_password(user, password) do
    hashed_password = Bcrypt.hash_pwd_salt(password)
    %{user | hashed_password: hashed_password}
  end

  def room_factory do
    %Harmony.Rooms.Room{
      title: sequence(:title, &"room#{&1}-name"),
      description: "Some description here"
    }
  end
end
