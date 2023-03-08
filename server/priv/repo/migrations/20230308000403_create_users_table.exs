defmodule RacquetFun.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :email, :string
      add :password, :string
      add :name, :string
      add :surname, :string
      add :active, :boolean, default: false
    end
  end
end
