defmodule RacquetFun.Repo.Migrations.CreateActivationsTable do
  use Ecto.Migration

  def change do
    create table("activation_ids") do
      add :activation_id, :string
      add :email, :string
      add :until, :date
      add :activated, :boolean, default: false
    end
  end
end
