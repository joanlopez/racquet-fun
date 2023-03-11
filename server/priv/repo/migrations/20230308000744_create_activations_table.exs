defmodule RacquetFun.Repo.Migrations.CreateActivationsTable do
  use Ecto.Migration

  def change do
    create table(:activation_ids) do
      add :id, :string, primary_key: true
      add :user_id, references(:users, type: :string, on_delete: :delete_all)
      add :until, :date
      add :activated, :boolean, default: false
    end
  end
end
