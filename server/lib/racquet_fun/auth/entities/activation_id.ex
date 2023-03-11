defmodule RacquetFun.Auth.Entities.ActivationId do
  @moduledoc """
  Structure and type for ActivationId entity.
  """

  alias Ecto.ULID, as: ULID
  alias RacquetFun.Auth.Entities

  @enforce_keys [:id, :user_id, :until, :activated]

  defstruct [
    :id,
    :user_id,
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
          id: String.t(),
          user_id: String.t(),
          until: Date.t(),
          activated: boolean
        }

  @schema %{
    id: [type: :string, required: true, length: [equal_to: 26]],
    user_id: [type: :string, required: true, length: [equal_to: 26]],
    until: [type: :date, required: true],
    activated: [type: :boolean, required: false]
  }

  @spec for(String.t()) :: {:ok, __MODULE__.t()} | {:ko, errors :: map()}
  def for(user_id) do
    params = %{
      id: ULID.generate(),
      user_id: user_id,
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
  @primary_key {:id, :string, autogenerate: false}

  schema "activation_ids" do
    # field :id, :string
    field :user_id, :string
    field :until, :date
    field :activated, :boolean, default: false
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :user_id, :until, :activated])
    |> validate_required([:id, :user_id, :until])
    |> unique_constraint(:id)
  end
end
