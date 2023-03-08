defmodule RacquetFun.Auth do
  @moduledoc """
  AuthZN context.
  """

  alias RacquetFun.Auth.{Events, Repo, Entities.User, Entities.ActivationId}

  @type email :: String.t()
  @type password :: String.t()
  @type name :: String.t()
  @type surname :: String.t()
  @type activation_id :: String.t()

  @doc """
  Signs up a new user with the corresponding email address and password,
  as well as other information details such as the user's full name.

  Asynchronous operation that can:
    - Early terminate (pre-conditions not satisfied)
    - Sign up (register/create) the user
    - Send a new account activation email
    - Sign magic in case the email already exists
  """
  @spec sign_up(email(), password(), name(), surname()) :: :ok | {:ko, map()}
  def sign_up(email, password, name, surname) do
    # Note: if at some point we do plan
    # to persist these events, the pwd
    # must be hashed.
    #
    # Be careful! Even if the event is not
    # persisted, it could be printed out
    # (leaked) into application logs.

    with {:ok, user} <-
           User.new(%{email: email, password: password, name: name, surname: surname}),
         {:ok, event} <- Events.UserSignedUp.new(%{user: user}) do
      EventBus.notify(event)
    end
  end

  @doc """
  Signs up a new user with the corresponding email address and password,
  as well as other information details such as the user's full name.

  Asynchronous operation that can:
    - Early terminate (pre-conditions not satisfied)
    - Sign up (register/create) the user
    - Send a new account activation email
    - Sign magic in case the email already exists
  """
  @spec activate(email(), activation_id()) :: :ok | {:ko, map()}
  def activate(email, activation_id) do
    case Repo.valid_activation_id_by_email(email, activation_id) do
      %ActivationId{} ->
        Repo.activate_user(email, activation_id)

      :not_found ->
        {:error, %{activation_id: ["not found"]}}
    end
  end
end

# RacquetFun.Auth.sign_up("email@exmaple.org", "my-secret-pwd", "Chat", "GPT")
