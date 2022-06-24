defmodule HarmonyWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      alias HarmonyWeb.Router.Helpers, as: Routes

      import Harmony.Factory
      import HarmonyWeb.FeatureHelpers
      @endpoint HarmonyWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Harmony.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Harmony.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Harmony.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
