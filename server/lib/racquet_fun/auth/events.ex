defmodule RacquetFun.Auth.Events do
  alias Ecto.ULID, as: ULID
  alias EventBus.Model.Event, as: BaseEvent

  def new(topic, module, params, schema) do
    with {:ok, verified} <- Tarams.cast(params, schema) do
      {:ok,
       %BaseEvent{
         id: ULID.generate(),
         topic: topic,
         data: struct(module, verified)
       }}
    end
  end
end
