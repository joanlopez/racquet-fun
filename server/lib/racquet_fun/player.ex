defmodule RacquetFun.Player do
  @moduledoc """
  Player context.
  """

  alias RacquetFun.Player.{Repo, Entities.Profile}

  @type user_id :: String.t()

  @doc """
  fixme

  RacquetFun.Player.get_profile("01GV07RHH5XME8D1SWMTJ1N45Q")
  """
  def get_profile(user_id) do
    case Repo.profile_by_user_id(user_id) do
      %Profile{} = profile ->
        {:ok, profile}

      :not_found ->
        {:error, %{user_id: ["not found"]}}
    end
  end
end
