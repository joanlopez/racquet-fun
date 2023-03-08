defmodule RacquetFun.Auth.Entities do
  def new(module, params, schema) do
    with {:ok, verified} <- Tarams.cast(params, schema) do
      {:ok, struct(module, verified)}
    end
  end
end
