defmodule RacquetFun.Auth.Repo do
  @moduledoc """
  Repository pattern for all the Auth.Entities
  """

  import Ecto.Query, only: [from: 2]

  alias RacquetFun.Repo
  alias RacquetFun.Auth.Entities.{User, ActivationId}

  # User functions
  def all_users() do
    User.Schema
    |> Repo.all()
    |> Enum.map(fn x -> user_from_schema(x) end)
  end

  def activate_user(email, activation_id) do
    # fixme: transaction
    # fixme: edge cases (no db conn, duplicated calls, etc)

    user_query = from(u in User.Schema, where: u.email == ^email)
    activation_query = from(id in ActivationId.Schema, where: id.activation_id == ^activation_id)

    with {1, _} <- Repo.update_all(user_query, set: [active: true]),
     {1, _} <- Repo.update_all(activation_query, set: [activated: true]) do
      :ok
      else
      _ -> :not_found
     end
  end

  defp user_from_schema(%User.Schema{} = entity) do
    attrs =
      entity
      |> Map.from_struct()
      |> Map.delete(:__meta__)

    struct(User, attrs)
  end

  @spec save_user(User.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def save_user(%User{} = user) do
    user
    |> Map.from_struct()
    |> User.Schema.changeset()
    |> Repo.insert()
  end

  # Activation id functions
  def all_activation_ids() do
    ActivationId.Schema
    |> Repo.all()
    |> Enum.map(fn x -> activation_id_from_schema(x) end)
  end

  def valid_activation_id_by_email(email, activation_id) do
    now = Date.utc_today()

    query =
      from id in ActivationId.Schema,
        where: id.email == ^email and id.activation_id == ^activation_id and id.until >= ^now

    case Repo.one(query) do
      %ActivationId.Schema{} = found ->
        activation_id_from_schema(found)

      nil ->
        :not_found
    end
  end

  defp activation_id_from_schema(%ActivationId.Schema{} = entity) do
    attrs =
      entity
      |> Map.from_struct()
      |> Map.delete(:__meta__)

    struct(ActivationId, attrs)
  end

  @spec save_activation_id(ActivationId.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def save_activation_id(%ActivationId{} = activation_id) do
    activation_id
    |> Map.from_struct()
    |> ActivationId.Schema.changeset()
    |> Repo.insert()
  end
end
