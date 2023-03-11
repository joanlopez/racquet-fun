defmodule RacquetFunUtil.Plug.Logger do
  require Logger
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :level, :info)
  end

  def call(conn, level) do
    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      Logger.log(level, fn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)

        {"",
         method: conn.method,
         path: conn.request_path,
         status_code: conn.status,
         elapsed: formatted_diff(diff)}
      end)

      conn
    end)
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [Integer.to_string(diff), "µs"]
end
