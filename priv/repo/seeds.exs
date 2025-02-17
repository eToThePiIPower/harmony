alias Harmony.Accounts
alias Harmony.Chat.{Room, Message}
alias Harmony.Repo

users = [
  {"Threepio", "3po@droid.net"},
  {"Ben", "obiwan@jedi.net"},
  {"Luke", "luke@skywalker.net"},
  {"Han", "han@falcon.ship"},
  {"Leia", "leia@alderan.planet"},
  {"Chewbacca", "chewie@falcon.ship"}
]

password = "help me obiwan"

for {username, email} <- users do
  Accounts.register_user(%{
    username: username,
    email: email,
    password: password,
    password_confirmation: password
  })
end

threepio = Accounts.get_user_by_email("3po@droid.net")
ben = Accounts.get_user_by_email("obiwan@jedi.net")
luke = Accounts.get_user_by_email("luke@skywalker.net")
han = Accounts.get_user_by_email("han@falcon.ship")
leia = Accounts.get_user_by_email("leia@alderan.planet")
chewie = Accounts.get_user_by_email("chewie@falcon.ship")

room = Repo.insert!(%Room{name: "death-star", topic: "Making the Galaxy Great Again"})

for {user, message} <- [
      {luke, "There isn't any other way out."},
      {han, "I can't hold them off forever! Now what?"},
      {leia,
       "This is some rescue. When you came in here, didn't you have a plan for getting out?"},
      {han, "He's the brains, sweetheart."},
      {luke, "Well, I didn't..."},
      {han, "What the hell are you doing?"},
      {leia, "Somebody has to save our skins. Into the garbage chute, fly boy!"},
      {chewie, "MURGHHHHH GRRBOKGH"},
      {han, "Wonderful girl! Either I'm going to kill her or I'm beginning to like her."},
      {han, "Get in there!"}
    ] do
  Repo.insert!(%Message{user: user, room: room, body: message})
end

room = Repo.insert!(%Room{name: "alderan", topic: "Currently undergoing renovation."})

for {user, message} <- [
      {han, "Not a bad bit of rescuing, hun?"},
      {leia,
       "That doesn't sound hard. Besides, they let us go. It's the only explanation for these of our escape."},
      {han, "Easy... you call that easy?"},
      {leia, "They're tracking us."},
      {han, "Not this ship, sister"},
      {leia, "At least the information in Artoo is still intact."},
      {han, "What's so important? What's he carrying?"},
      {leia, "The technical readouts of that battle station."},
      {leia, "I only hope that when the data is anlyzed, a weakness can be found."},
      {leia, "It's not over yet."}
    ] do
  Repo.insert!(%Message{user: user, room: room, body: message})
end

room = Repo.insert!(%Room{name: "tatooine", topic: "Two suns are better than one."})

for {user, message} <- [
      {threepio, "He made a fair move. Screaming about it won't help you."},
      {han, "Let him have it. It's not wise to upset a Wookie."},
      {threepio, "But sir, nobody worries about upsetting a droid"},
      {han,
       "That's 'cause droids don't pull people's arms out of their sockets when they lose. Wookies are known to do that.."},
      {chewie, "HRUNG"},
      {threepio, "I see your point, sir. I suggest a new strategy, Artoo. Let the Wookie win."},
      {ben, "Remember, a Jedi can feel the Force flowing through him."},
      {luke, "You mean it controls your actions?"},
      {ben, "Partially, but it also obeys your commands."}
    ] do
  Repo.insert!(%Message{user: user, room: room, body: message})
end
