# Harmony

Harmony is an open-source, real-time chat application --- in the vein of classic
IRC, Slack, & Discord---powered by Phoenix LiveView.

![build](https://github.com/etothepiipower/harmony/actions/workflows/build.yml/badge.svg?branch=develop)

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Create and migrate your database with 'mix ecto.setup'
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Contributing

We use `ExUnit`` to test the application and (planned) GitHub Actions to run the tests in CI.

 *  Fork the repository
 *  Create a new branch `feature/*feature-name*`
 *  Write tests and implementation code
 *  Run the test suite with `mix test`
 *  Push your changes to your fork
 *  Once the tests pass in CI, you can submit a pull request.

Because we are using [ PhoenixTest ](https://hexdocs.pm/phoenix_test/PhoenixTest.html)
for feature tests, we don't need Chromedriver. Yay!

## Planned Features

Harmony is in an early stage right now. Planned features include:

    * [x]    Rooms
    * [ ]    Messages
    * [ ]    Room groups and ordering
    * [ ]    User profiles
    * [ ]    User roles (admin, moderator, user)
    * [ ]    More...
