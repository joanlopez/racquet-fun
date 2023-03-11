defmodule RacquetFun.Repo.Migrations.CreatePlayerProfilesTable do
  use Ecto.Migration

  def change do
    create table(:player_profiles) do
      add :id, :string, primary_key: true
      add :email, :string
      add :name, :string
      add :surname, :string
      add :user_id, references(:users, type: :string, on_delete: :delete_all)
    end

    create unique_index(:player_profiles, [:email])
  end
end
