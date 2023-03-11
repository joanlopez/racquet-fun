defmodule RacquetFunUtil.Logger.Logfmt do
  alias RacquetFunUtil.Sanitizer

  def format(level, message, timestamp, metadata) do
    base = [{:level, level}, {:ts, timestamp_to_string(timestamp)}]

    fmt_line =
      cond do
        message == "" -> base
        true -> base ++ [{:msg, message}]
      end

    [
      (fmt_line ++ metadata)
      |> Sanitizer.sanitize_keyword()
      |> Logfmt.encode(output: :iolist),
      "\n"
    ]
  rescue
    _ -> "LOG_FORMATTER_ERROR: #{inspect({level, message, timestamp, metadata})}\n"
  end

  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch :calendar.datetime_to_gregorian_seconds(epoch)

  defp timestamp_to_string(timestamp) do
    {date, {h, m, s, millis}} = timestamp

    timestamp =
      :erlang.localtime_to_universaltime({date, {h, m, s}})
      |> :calendar.datetime_to_gregorian_seconds()
      |> Kernel.-(@epoch)

    (timestamp * 1000 + millis)
    |> :calendar.system_time_to_rfc3339(unit: :millisecond)
    |> to_string()
  end
end
