# Harmony ![example branch parameter](https://github.com/etothepiipower/harmony/actions/workflows/elixir-ci.yml/badge.svg?branch=develop)

Harmony is an open-source, real-time chat application---in the vein of classic
IRC, Slack, & Discord---powered by Phoenix LiveView.

To get started:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributing

We use `ExUnit` to test the application and GitHub Actions to run the tests in
CI.

  * Fork the repository
  * Create a new branch `feature.<feature-name>`
  * Write tests and implementation code
  * Run the test suite with `mix test`
  * Consider installing [ nektos/act ](https://github.com/nektos/act) to run the
    CI script locally in Docker
    - Run the workflow locally with `act`
    - Important if you're modifying `/.github/workflows/*.yml` or `/config/**`
  * Push your changes to your fork
  * Once the tests pass in CI, you can submit a pull request.

Because we are using [ Wallaby  ](https://hex.pm/packages/wallaby) for feature
tests, we'll need to install `chromedriver` and a matching version of either
`google-chrome` or `chromium-browser` via your operating system.

## Planned Features

Harmony is in an early stage right now. Planned features include:

  * [ ] User roles (admin, moderator, user)
  * [ ] Channels/Room
  * [ ] Channel/Room messages
  * [ ] Channel/Room groups
  * [ ] User profiles
  * [ ] More...
