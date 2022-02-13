defmodule ChurchApp.Repo.Migrations.AddSubsIdAndPeriodEnd do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :subscription_id, :string
      add :current_period_end, :utc_datetime
    end
  end
end
