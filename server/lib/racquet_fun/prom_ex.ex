defmodule RacquetFun.PromEx do
  use PromEx, otp_app: :racquet_fun

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: RacquetFunWeb.Router, endpoint: RacquetFunWeb.Endpoint},
      Plugins.Ecto,
      # Plugins.Oban,
      Plugins.PhoenixLiveView

      # Add your own PromEx metrics plugins
      # RacquetFun.Users.PromExPlugin
    ]
  end

  @impl true
  def dashboard_assigns, do: []

  @impl true
  def dashboards, do: []
end
