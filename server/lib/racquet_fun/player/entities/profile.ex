defmodule RacquetFun.Player.Entities.Profile do
  @moduledoc """
  Structure and type for Profile entity.
  """

  alias Ecto.ULID, as: ULID
  alias RacquetFun.Player.Entities

  @enforce_keys [:id, :email, :name, :surname, :user_id]

  defstruct [
    :id,
    :email,
    :name,
    :surname,
    :user_id
  ]

  @typedoc """
  Definition of the Profile struct.

  * :id - Profile identifier
  * :email - Email address
  * :name - Name
  * :surname - Surname
  * :user_id - User identifier
  """
  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t(),
          name: String.t(),
          surname: String.t(),
          user_id: String.t()
        }

  @schema %{
    id: [type: :string, required: true, length: [equal_to: 26]],
    email: [type: :string, required: true, length: [min: 6]],
    name: [type: :string, required: true, length: [min: 2]],
    surname: [type: :string, required: true, length: [min: 2]],
    user_id: [type: :string, required: true, length: [equal_to: 26]]
  }

  @spec new(%{
          required(:email) => String.t(),
          required(:name) => String.t(),
          required(:surname) => String.t(),
          required(:user_id) => String.t()
        }) :: {:ok, __MODULE__.t()} | {:ko, errors :: map()}
  def new(params) do
    attrs =
      params
      |> Map.put(:id, ULID.generate())

    Entities.new(__MODULE__, attrs, @schema)
  end
end

defmodule RacquetFun.Player.Entities.Profile.Schema do
  @moduledoc """
  Storage schema for Profile entity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :string, autogenerate: false}

  schema "player_profiles" do
    # field :id, :string
    field :email, :string
    field :name, :string
    field :surname, :string
    field :user_id, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :email, :name, :surname, :user_id])
    |> validate_required([:id, :email, :name, :surname, :user_id])
    |> unique_constraint(:user_id)
  end
end
