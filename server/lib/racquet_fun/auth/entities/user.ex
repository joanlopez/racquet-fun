defmodule RacquetFun.Auth.Entities.User do
  @moduledoc """
  Structure and type for User entity.
  """

  import Bcrypt
  alias Ecto.ULID, as: ULID
  alias RacquetFun.Auth.Entities

  @enforce_keys [:id, :email, :password, :name, :surname, :active]

  defstruct [
    :id,
    :email,
    :password,
    :name,
    :surname,
    :active
  ]

  @typedoc """
  Definition of the User struct.

  * :id - User identifier
  * :email - Email address
  * :password - Password
  * :name - Name
  * :surname - Surname
  """
  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t(),
          password: String.t(),
          name: String.t(),
          surname: String.t(),
          active: boolean
        }

  @schema %{
    id: [type: :string, required: true, length: [equal_to: 26]],
    email: [type: :string, required: true, length: [min: 6]],
    password: [type: :string, required: true, length: [min: 8]],
    name: [type: :string, required: true, length: [min: 2]],
    surname: [type: :string, required: true, length: [min: 2]],
    active: [type: :boolean, required: false]
  }

  @spec new(%{
          required(:email) => String.t(),
          required(:password) => String.t(),
          required(:name) => String.t(),
          required(:surname) => String.t()
        }) :: {:ok, __MODULE__.t()} | {:ko, errors :: map()}
  def new(params) do
    with {:ok, hash} <- hash_password(params.password) do
      attrs =
        params
        |> Map.put(:id, ULID.generate())
        |> Map.put(:password, hash)
        |> Map.put(:active, false)

      Entities.new(__MODULE__, attrs, @schema)
    end
  end

  defp hash_password(password) do
    case add_hash(password) do
      %{password_hash: password_hash} -> {:ok, password_hash}
    end
  end
end

defmodule RacquetFun.Auth.Entities.User.Schema do
  @moduledoc """
  Storage schema for User entity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :string, autogenerate: false}

  schema "users" do
    # field :id, :string
    field :email, :string
    field :password, :string
    field :name, :string
    field :surname, :string
    field :active, :boolean, default: false
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :email, :password, :name, :surname, :active])
    |> validate_required([:id, :email, :password, :name, :surname])
    |> unique_constraint(:email)
  end
end
