defmodule RacquetFunWeb.Player.Controller do
  use RacquetFunWeb, :controller
  use RacquetFunUtil.Map

  alias RacquetFun.Player

  alias Tarams
  alias Ecto.ULID, as: ULID

  @get_profile_schema %{
    user_id: [type: :string, required: true, length: [equal_to: 26]]
  }

  # curl 127.0.0.1:4000/api/player/profile\?user_id=123

  def get_profile(conn, params) do
    with {:ok, ~m{user_id}} <- params |> Tarams.cast(@get_profile_schema),
         {:ok, _user_id} <- ULID.cast(user_id),
         {:ok, %RacquetFun.Player.Entities.Profile{} = profile} <- Player.get_profile(user_id) do
      conn
      |> put_status(200)
      |> json(%{status: "ok", data: Map.from_struct(profile)})
    else
      {:error, errors} ->
        return_errors(conn, errors)
    end
  end

  defp return_errors(conn, errors) do
    conn
    # fixme: 401, 404, 500...
    |> put_status(400)
    |> json(%{status: "ko", errors: errors})
  end
end
