defmodule RacquetFun.Auth do
  @moduledoc """
  AuthNZ context.
  """

  alias Bcrypt
  alias RacquetFun.Auth.{Events, Repo, Entities.User, Entities.ActivationId, Guardian}

  @type email :: String.t()
  @type password :: String.t()
  @type name :: String.t()
  @type surname :: String.t()

  @type user_id :: String.t()
  @type activation_id :: String.t()

  @doc """
  Signs up a new user with the corresponding email address and password,
  as well as other information details such as the user's full name.

  Asynchronous operation that can:
    - Early terminate (pre-conditions not satisfied)
    - Sign up (register/create) the user
    - Send a new account activation email
    - Sign magic in case the email already exists

  RacquetFun.Auth.sign_up("email@exmaple.org", "my-secret-pwd", "Chat", "GPT")
  """
  @spec sign_up(email(), password(), name(), surname()) :: :ok | {:ko, map()}
  def sign_up(email, password, name, surname) do
    with {:ok, user} <-
           User.new(%{email: email, password: password, name: name, surname: surname}),
         {:ok, event} <- Events.UserSignedUp.new(%{user: user}) do
      EventBus.notify(event)
    end
  end

  @doc """
  fixme

  RacquetFun.Auth.activate("01GV07RHH5XME8D1SWMTJ1N45Q", "01GV07RHHPWPQ0FPBFG2WTRHQZ")
  """
  @spec activate(user_id(), activation_id()) :: :ok | {:ko, map()}
  def activate(user_id, activation_id) do
    # fixme: invert; transaction
    with %ActivationId{} <- Repo.activation_id_by_email(activation_id, user_id),
         :ok <- Repo.user_activate(user_id, activation_id),
         %User{} = user <- Repo.user_by_id(user_id),
         {:ok, event} <- Events.UserActivated.new(%{user: user}) do
      EventBus.notify(event)
    else
      :not_found ->
        {:error, %{activation_id: ["not found"]}}
    end
  end

  @doc """
  fixme

  RacquetFun.Auth.sign_in("email@exmaple.org", "my-secret-pwd")
  """
  @spec sign_in(email(), password()) :: :ok | {:ko, map()}
  def sign_in(email, password) do
    # fixme: brute force
    case Repo.user_by_email(email) do
      %User{} = user ->
        with :ok <- verify_pass(user, password),
             :ok <- verify_active(user) do
          generate_jwt(user)
        else
          error -> error
        end

      :not_found ->
        {:error, %{user: ["not found"]}}
    end
  end

  defp verify_pass(user, password) do
    case Bcrypt.verify_pass(password, user.password) do
      true -> :ok
      _ -> {:error, %{user: ["not found"]}}
    end
  end

  defp verify_active(%User{active: true}), do: :ok
  defp verify_active(_), do: {:error, %{user: ["not active"]}}

  defp generate_jwt(%User{} = user) do
    case Guardian.encode_and_sign(user) do
      {:ok, token, _claims} -> {:ok, token}
      _ -> {:error, %{user: ["unknown"]}}
    end
  end
end
