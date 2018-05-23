defmodule Fox.Repo.Migrations.CreateAction do
  use Ecto.Migration

  def change do
    create table(:action, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, size: 20)
      add(:percent, :integer)
      add(:frames, :integer)

      timestamps()
    end
  end
end
