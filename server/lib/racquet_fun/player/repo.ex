defmodule RacquetFun.Player.Repo do
  @moduledoc """
  Repository pattern for all the Auth.Entities
  """

  import Ecto.Query, only: [from: 2]

  alias RacquetFun.Repo
  alias RacquetFun.Player.Entities.{Profile}

  # Profile functions
  def profile_all() do
    Profile.Schema
    |> Repo.all()
    |> Enum.map(fn x -> profile_from_schema(x) end)
  end

  def profile_by_user_id(user_id) do
    case Repo.one(from p in Profile.Schema, where: p.user_id == ^user_id) do
      %Profile.Schema{} = found ->
        profile_from_schema(found)

      nil ->
        :not_found
    end
  end

  @spec profile_save(Profile.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def profile_save(%Profile{} = profile) do
    profile
    |> Map.from_struct()
    |> Profile.Schema.changeset()
    |> Repo.insert()
  end

  defp profile_from_schema(%Profile.Schema{} = entity) do
    attrs =
      entity
      |> Map.from_struct()
      |> Map.delete(:__meta__)

    struct(Profile, attrs)
  end
end
