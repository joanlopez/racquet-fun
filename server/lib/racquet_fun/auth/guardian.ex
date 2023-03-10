defmodule RacquetFun.Auth.Guardian do
  use Guardian, otp_app: :racquet_fun

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :reason_for_error}

  def resource_from_claims(%{"sub" => id}), do: {:ok, id}
  def resource_from_claims(_claims), do: {:error, :reason_for_error}
end
