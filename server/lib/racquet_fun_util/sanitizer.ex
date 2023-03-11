defmodule RacquetFunUtil.Sanitizer do
  def sanitize_keyword(keywords), do: Enum.map(keywords, fn {k, v} -> {k, sanitize(v)} end)

  def sanitize(value) when is_atom(value) do
    string_atom = Atom.to_string(value)

    with "Elixir." <> no_prefix_string <- string_atom do
      no_prefix_string
    end
  end

  def sanitize(value) when is_binary(value), do: value

  def sanitize(value) when is_integer(value), do: Integer.to_string(value)

  def sanitize(value) when is_float(value), do: Float.to_string(value)

  def sanitize(value) when is_pid(value) or is_port(value) or is_reference(value),
    do: inspect(value)

  def sanitize([{k, _v} | _tail] = value) when is_atom(k), do: base64_encode_term(value)

  def sanitize([a | _tail] = value) when is_atom(a), do: base64_encode_term(value)

  def sanitize(value) when is_list(value) do
    :erlang.iolist_to_binary(value)
  rescue
    _ ->
      base64_encode_term(value)
  end

  def sanitize(value), do: base64_encode_term(value)

  defp base64_encode_term(value),
    do: "base64-encoded-term:" <> (value |> :erlang.term_to_binary() |> Base.encode64())
end
