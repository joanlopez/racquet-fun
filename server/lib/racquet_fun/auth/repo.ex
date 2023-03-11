defmodule RacquetFun.Auth.Repo do
  @moduledoc """
  Repository pattern for all the Auth.Entities
  """

  import Ecto.Query, only: [from: 2]

  alias RacquetFun.Repo
  alias RacquetFun.Auth.Entities.{User, ActivationId}

  # User functions
  def user_all() do
    User.Schema
    |> Repo.all()
    |> Enum.map(fn x -> user_from_schema(x) end)
  end

  def user_by_id(id) do
    case Repo.one(from u in User.Schema, where: u.id == ^id) do
      %User.Schema{} = found ->
        user_from_schema(found)

      nil ->
        :not_found
    end
  end

  def user_by_email(email) do
    case Repo.one(from u in User.Schema, where: u.email == ^email) do
      %User.Schema{} = found ->
        user_from_schema(found)

      nil ->
        :not_found
    end
  end

  @spec user_save(User.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def user_save(%User{} = user) do
    user
    |> Map.from_struct()
    |> User.Schema.changeset()
    |> Repo.insert()
  end

  def user_activate(user_id, activation_id) do
    # fixme: transaction
    # fixme: edge cases (no db conn, duplicated calls, etc)

    user_query = from(u in User.Schema, where: u.id == ^user_id)
    activation_query = from(id in ActivationId.Schema, where: id.id == ^activation_id)

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

  # Activation id functions
  def activation_id_all() do
    ActivationId.Schema
    |> Repo.all()
    |> Enum.map(fn x -> activation_id_from_schema(x) end)
  end

  @spec activation_id_save(ActivationId.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def activation_id_save(%ActivationId{} = activation_id) do
    activation_id
    |> Map.from_struct()
    |> ActivationId.Schema.changeset()
    |> Repo.insert()
  end

  def activation_id_by_email(id, user_id) do
    now = Date.utc_today()

    query =
      from id in ActivationId.Schema,
        where: id.id == ^id and id.user_id == ^user_id and id.until >= ^now

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
end
