defmodule RacquetFunWeb.Auth.ErrorHandler do
  require Logger

  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    Logger.warn("Authentication error (#{type})")

    conn
    |> put_status(401)
    |> Phoenix.Controller.json(%{status: "ko", errors: %{user: ["unauthorized"]}})
  end
end
