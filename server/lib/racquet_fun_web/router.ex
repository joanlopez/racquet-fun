defmodule RacquetFunWeb.Router do
  use RacquetFunWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug RacquetFunUtil.Plug.Logger, level: :info
  end

  pipeline :authenticated do
    plug Guardian.Plug.VerifyHeader,
      module: RacquetFun.Auth.Guardian,
      error_handler: RacquetFunWeb.Auth.ErrorHandler
  end

  scope "/api/auth", RacquetFunWeb do
    pipe_through :api

    post "/sign-up", Auth.Controller, :sign_up
    get "/activate", Auth.Controller, :activate
    post "/sign-in", Auth.Controller, :sign_in
  end

  scope "/api/player", RacquetFunWeb do
    pipe_through [:api, :authenticated]

    get "/profile", Player.Controller, :get_profile
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RacquetFunWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
