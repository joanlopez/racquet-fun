defmodule RacquetFun.Auth.Events.UserActivated do
  alias Tarams
  alias RacquetFun.Auth.{Events, Entities.User}

  defstruct [
    :user
  ]

  @type t :: %__MODULE__{
          user: User.t()
        }

  @topic :user_activated

  @schema %{
    user: [type: :struct, required: true]
  }

  @spec new(User.t()) :: {:ok, __MODULE__.t()} | {:ko, errors :: map()}
  def new(params), do: Events.new(@topic, __MODULE__, params, @schema)
end
