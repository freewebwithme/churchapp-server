defmodule ChurchAppWeb.Resolvers.Admin do
  alias ChurchApp.Accounts

  def list_users(_, _, _) do
    {:ok, Accounts.list_users()}
  end

  def get_user(_, %{id: id}, _) do
    {:ok, Accounts.get_user(id)}
  end

  def update_key_info(_, args, _) do
    %{church_id: church_id} = args
    church = Accounts.get_church_by_id(church_id)
    Accounts.update_church(church, args)
  end
end
