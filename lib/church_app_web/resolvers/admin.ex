defmodule ChurchAppWeb.Resolvers.Admin do
  alias ChurchApp.Accounts

  def list_users(_, _, _) do
    {:ok, Accounts.list_users()}
  end
end
