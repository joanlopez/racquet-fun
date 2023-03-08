defmodule RacquetFun.Auth.Consumers.UserSignedUp do
  @moduledoc """
  Events.UserSignedUp consumer.
  """

  import Bcrypt
  alias EventBus.Model.Event, as: BaseEvent
  alias RacquetFun.Mailer
  alias RacquetFun.Auth.{Repo, Entities.ActivationId, Events.UserSignedUp}

  require Logger

  def process({:user_signed_up, _id} = event) do
    consume(EventBus.fetch_event(event))
    EventBus.mark_as_completed({__MODULE__, event})
  end

  def process(event) do
    Logger.error(["Unsupported event: ", event])
  end

  defp consume(%BaseEvent{data: %UserSignedUp{user: user}} = event) do
    Logger.info("Consuming event: #{inspect(event)}")

    # In case of (db) error we need to retry it?
    with {:ok, activation_id} <- ActivationId.for(user.email),
         {:ok, _activation_id_res} <- Repo.save_activation_id(activation_id),
         {:ok, password_hash} <- hash_password(user.password),
         {:ok, _user_res} <- save_user(%{user | password: password_hash}),
         {:ok, _email_res} <- send_welcome_email(user, activation_id) do
      :ok
    end
  end

  defp consume(%BaseEvent{} = event) do
    Logger.error(["Unsupported event: ", event])
  end

  defp hash_password(password) do
    case add_hash(password) do
      %{password_hash: password_hash} -> {:ok, password_hash}
    end
  end

  defp save_user(user) do
    case Repo.save_user(user) do
      {:ok, result} ->
        Logger.info("User(#{user.email}) successfully stored into the database")
        {:ok, result}

      {:error, errors} ->
        Logger.error(
          "User(#{user.email}) could not be stored into the database: #{inspect(errors)}"
        )

        {:error, errors}
    end
  end

  defp send_welcome_email(user, activation_id) do
    full_name = user.name <> " " <> user.surname

    case Mailer.UserWelcome.build({full_name, user.email}, activation_id) |> Mailer.deliver() do
      {:ok, result} ->
        Logger.info("User(#{user.email}) welcome email successfully sent")
        {:ok, result}

      {:error, error} ->
        Logger.error("User(#{user.email}) welcome email could not be sent: #{inspect(error)}")
        {:error, error}
    end
  end
end
