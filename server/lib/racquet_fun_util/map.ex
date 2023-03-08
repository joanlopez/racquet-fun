defmodule RacquetFunUtil.Map do
  defmacro __using__(_) do
    quote do: import(unquote(__MODULE__))
  end

  defmacro sigil_m({:<<>>, _line, [string]}, []) do
    spec =
      string
      |> String.split()
      |> Stream.map(&String.to_atom/1)
      |> Enum.map(&{&1, {&1, [], nil}})

    {:%{}, [], spec}
  end
end
