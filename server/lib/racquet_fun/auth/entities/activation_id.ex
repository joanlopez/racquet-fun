defmodule RacquetFun.Auth.Entities.ActivationId do
  @moduledoc """
  Structure and type for ActivationId entity.
  """

  alias Ecto.ULID, as: ULID
  alias RacquetFun.Auth.Entities

  @enforce_keys [:email, :activation_id, :until, :activated]

  defstruct [
    :email,
    :activation_id,
    :until,
    :activated
  ]

  @typedoc """
  Definition of the ActivationId struct.

  * :email - Email address
  * :activation_id - Activation id
  * :until - Date for which the id is valid
  """
  @type t :: %__MODULE__{
          email: String.t(),
          activation_id: String.t(),
          until: Date.t(),
          activated: boolean
        }

  @schema %{
    email: [type: :string, required: true, length: [min: 6]],
    activation_id: [type: :string, required: true, length: [equal_to: 26]],
    until: [type: :date, required: true],
    activated: [type: :boolean, required: false]
  }

  @spec for(%{required(:email) => String.t()}) :: {:ok, __MODULE__.t()} | {:ko, errors :: map()}
  def for(email) do
    params = %{
      email: email,
      activation_id: ULID.generate(),
      until: Date.utc_today(),
      activated: false
    }

    Entities.new(__MODULE__, params, @schema)
  end
end

defmodule RacquetFun.Auth.Entities.ActivationId.Schema do
  @moduledoc """
  Storage schema for ActivationId entity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:activation_id, :string, autogenerate: false}

  schema "activation_ids" do
    # field :activation_id, :string
    field :email, :string
    field :until, :date
    field :activated, :boolean, default: false
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :activation_id, :until, :activated])
    |> validate_required([:email, :activation_id, :until])
    |> unique_constraint(:activation_id)
  end
end
