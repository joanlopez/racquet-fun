defmodule RacquetFunWeb.AuthController do
  use RacquetFunWeb, :controller
  use RacquetFunUtil.Map

  alias RacquetFun.Auth

  alias Tarams
  alias Ecto.ULID, as: ULID

  @signup_schema %{
    email: [type: :string, required: true, length: [min: 6]],
    password: [type: :string, required: true, length: [min: 8]],
    name: [type: :string, required: true, length: [min: 2]],
    surname: [type: :string, required: true, length: [min: 2]]
  }

  # curl -X POST  127.0.0.1:4000/api/auth/sign-up -H 'Content-Type: application/json' -d '{"email": "joan@gmail.com", "password": "12345678", "name": "Jo", "surname": "Rodríguez"}'

  def sign_up(conn, params) do
    with {:ok, ~m{email password name surname}} <- params |> Tarams.cast(@signup_schema),
         :ok <- Auth.sign_up(email, password, name, surname) do
      conn
      |> put_status(202)
      |> json(%{status: "ok"})
    else
      {:error, errors} -> conn |> put_status(400) |> json(%{status: "ko", errors: errors})
    end
  end

  @activate_schema %{
    email: [type: :string, required: true, length: [min: 6]],
    activation_id: [type: :string, required: true, length: [min: 10]]
  }

  # curl 127.0.0.1:4000/api/auth/activate\?email=joan@gmail.com&activation_id=123

  def activate(conn, params) do
    with {:ok, ~m{email activation_id}} <- params |> Tarams.cast(@activate_schema),
         {:ok, _ulid} <- ULID.cast(activation_id),
         :ok <- Auth.activate(email, activation_id) do
      conn
      |> put_status(200)
      |> json(%{status: "ok"})
    else
      {:error, errors} ->
        return_errors(conn, errors)

      :error ->
        return_errors(conn, %{activation_id: ["is invalid"]})
    end
  end

  defp return_errors(conn, errors) do
    conn
    |> put_status(400)
    |> json(%{status: "ko", errors: errors})
  end
end
