defmodule RacquetFunWeb.Auth.Controller do
  use RacquetFunWeb, :controller
  use RacquetFunUtil.Map

  alias RacquetFun.Auth

  alias Tarams
  alias Ecto.ULID, as: ULID

  @sign_up_schema %{
    email: [type: :string, required: true, length: [min: 6]],
    password: [type: :string, required: true, length: [min: 8]],
    name: [type: :string, required: true, length: [min: 2]],
    surname: [type: :string, required: true, length: [min: 2]]
  }

  # curl -X POST  127.0.0.1:4000/api/auth/sign-up -H 'Content-Type: application/json' -d '{"email": "joan@gmail.com", "password": "12345678", "name": "Jo", "surname": "Rodríguez"}'

  def sign_up(conn, params) do
    with {:ok, ~m{email password name surname}} <- params |> Tarams.cast(@sign_up_schema),
         :ok <- Auth.sign_up(email, password, name, surname) do
      conn
      |> put_status(202)
      |> json(%{status: "ok"})
    else
      {:error, errors} -> conn |> put_status(400) |> json(%{status: "ko", errors: errors})
    end
  end

  @activate_schema %{
    user_id: [type: :string, required: true, length: [equal_to: 26]],
    activation_id: [type: :string, required: true, length: [equal_to: 26]]
  }

  # curl 127.0.0.1:4000/api/auth/activate\?user_id=123&activation_id=456

  def activate(conn, params) do
    with {:ok, ~m{user_id activation_id}} <- params |> Tarams.cast(@activate_schema),
         {:ok, _user_id} <- ULID.cast(user_id),
         {:ok, _activation_id} <- ULID.cast(activation_id),
         :ok <- Auth.activate(user_id, activation_id) do
      conn
      |> put_status(200)
      |> json(%{status: "ok"})
    else
      {:error, errors} ->
        return_errors(conn, errors)

      :error ->
        # fixme: technically not correct
        return_errors(conn, %{user_id: ["is invalid"], activation_id: ["is invalid"]})
    end
  end

  @sign_in_schema %{
    email: [type: :string, required: true, length: [min: 6]],
    password: [type: :string, required: true, length: [min: 8]]
  }

  # curl -X POST  127.0.0.1:4000/api/auth/sign-up -H 'Content-Type: application/json' -d '{"email": "joan@gmail.com", "password": "12345678"}'

  def sign_in(conn, params) do
    with {:ok, ~m{email password}} <- params |> Tarams.cast(@sign_in_schema),
         {:ok, token} <- Auth.sign_in(email, password) do
      conn
      |> put_status(200)
      |> json(%{status: "ok", data: %{token: token}})
    else
      {:error, errors} ->
        return_errors(conn, errors)
    end
  end

  defp return_errors(conn, errors) do
    conn
    |> put_status(400)
    |> json(%{status: "ko", errors: errors})
  end
end
