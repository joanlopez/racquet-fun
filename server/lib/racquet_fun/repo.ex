defmodule RacquetFun.Repo do
  use Ecto.Repo,
    otp_app: :racquet_fun,
    adapter: Ecto.Adapters.Postgres
end
