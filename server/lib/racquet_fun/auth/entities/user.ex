defmodule RacquetFun.Auth.Entities.User do
  @moduledoc """
  Structure and type for User entity.
  """

  alias RacquetFun.Auth.Entities

  @enforce_keys [:email, :password, :name, :surname, :active]

  defstruct [
    :email,
    :password,
    :name,
    :surname,
    :active
  ]

  @typedoc """
  Definition of the User struct.

  * :email - Email address
  * :password - Password
  * :name - Name
  * :surname - Surname
  """
  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t(),
          name: String.t(),
          surname: String.t(),
          active: boolean
        }

  @schema %{
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
  def new(params), do: Entities.new(__MODULE__, Map.put(params, :active, false), @schema)
end

defmodule RacquetFun.Auth.Entities.User.Schema do
  @moduledoc """
  Storage schema for User entity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:email, :string, autogenerate: false}

  schema "users" do
    # field :email, :string
    field :password, :string
    field :name, :string
    field :surname, :string
    field :active, :boolean, default: false
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :password, :name, :surname, :active])
    |> validate_required([:email, :password, :name, :surname])
    |> unique_constraint(:name)
  end
end
