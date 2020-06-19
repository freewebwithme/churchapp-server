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
    # Add has_key true to args map
    args = Map.put(args, :has_key, true)
    Accounts.update_church(church, args)
  end

  def change_active_state(_, %{church_id: church_id, active: active}, _) do
    # Get Church
    church = Accounts.get_church_by_id(church_id)

    case Accounts.update_church(church, %{active: active}) do
      {:ok, _church} ->
        {:ok, %{success: true, message: "Church's active state has been changed successfully"}}

      _ ->
        {:ok, %{success: false, message: "Church's active state hasn't been changed."}}
    end
  end
end
