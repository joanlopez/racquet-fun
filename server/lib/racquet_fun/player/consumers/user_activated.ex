defmodule RacquetFun.Player.Consumers.UserActivated do
  @moduledoc """
  Auth.Events.UserActivated consumer.
  """

  alias EventBus.Model.Event, as: BaseEvent
  alias RacquetFun.Auth.{Events.UserActivated}
  alias RacquetFun.Player.{Repo, Entities.Profile}

  require Logger

  def process({:user_activated, _id} = event) do
    consume(EventBus.fetch_event(event))
    EventBus.mark_as_completed({__MODULE__, event})
  end

  def process(event) do
    Logger.error(["Unsupported event: ", event])
  end

  defp consume(%BaseEvent{data: %UserActivated{user: u}} = event) do
    Logger.info("Consuming event: #{inspect(event)}")

    with {:ok, profile} <-
           Profile.new(%{email: u.email, name: u.name, surname: u.surname, user_id: u.id}) do
      save_profile(profile)
    end
  end

  defp consume(%BaseEvent{} = event) do
    Logger.error(["Unsupported event: ", event])
  end

  defp save_profile(profile) do
    case Repo.profile_save(profile) do
      {:ok, result} ->
        Logger.info(
          "Profile for user_id (#{profile.user_id}) successfully stored into the database"
        )

        {:ok, result}

      {:error, errors} ->
        Logger.error(
          "Profile for user_id (#{profile.user_id}) could not be stored into the database: #{inspect(errors)}"
        )

        {:error, errors}
    end
  end
end
