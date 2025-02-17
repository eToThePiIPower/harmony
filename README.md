# Harmony

Harmony is an open-source, real-time chat application --- in the vein of classic
IRC, Slack, & Discord---powered by Phoenix LiveView.

[![build](https://github.com/etothepiipower/harmony/actions/workflows/build.yml/badge.svg?branch=develop)](https://github.com/etothepiipower/harmony/actions/workflows/build.yml)

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Create and migrate your database with `mix ecto.setup`
  * Download npm assets with `cd assets && npm install && cd ..`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Optionally, run `mix run priv/repo/seeds.exs` to add some sample data

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributing

We use `ExUnit`` to test the application and (planned) GitHub Actions to run the tests in CI.

 *  Fork the repository
 *  Create a new branch `feature/*feature-name*`
 *  Write tests and implementation code
 *  Run the test suite with `mix test`
 *  Push your changes to your fork
 *  Once the tests pass locally, you can submit a pull request. The CI workflow
    will run the tests again and a maintainer will consider your changes.

Because we are using [ PhoenixTest ](https://hexdocs.pm/phoenix_test/PhoenixTest.html)
for feature tests, we don't need Chromedriver. Yay!

## Planned Features

Harmony is in an early stage right now. Planned features include:

    * [x]    Rooms
    * [x]    Messages
    * [ ]    Room groups and ordering
    * [ ]    User profiles
    * [ ]    User roles (admin, moderator, user)
    * [ ]    More...
