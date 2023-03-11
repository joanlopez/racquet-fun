defmodule RacquetFun.Auth.Consumers.UserSignedUp do
  @moduledoc """
  Events.UserSignedUp consumer.
  """

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

    # fixme: retries; idempotency
    with {:ok, _user_res} <- save_user(user),
         {:ok, activation_id} <- ActivationId.for(user.id),
         {:ok, _activation_id_res} <- Repo.activation_id_save(activation_id),
         {:ok, _email_res} <- send_welcome_email(user, activation_id) do
      :ok
    end
  end

  defp consume(%BaseEvent{} = event) do
    Logger.error(["Unsupported event: ", event])
  end

  defp save_user(user) do
    case Repo.user_save(user) do
      {:ok, result} ->
        Logger.info("User(#{user.email}) successfully stored into the database")
        {:ok, result}

      error ->
        # In case of unique constraint, here is how it looks like:
        # [email: {"has already been taken", [constraint: :unique, constraint_name: "users_email_index"]}]
        case error do
          {:error, %Ecto.Changeset{errors: errors}} ->
            Logger.error(
              "User(#{user.email}) could not be stored into the database: #{inspect(errors)}"
            )

          {:error, errors} ->
            Logger.error(
              "User(#{user.email}) could not be stored into the database: #{inspect(errors)}"
            )
        end

        error
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
