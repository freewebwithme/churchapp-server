defmodule ChurchApp.Encrypted.Binary do
  @moduledoc """
   This module is for cloak ecto package
   This is used for encrypting various key value to database
  """
  use Cloak.Ecto.Binary, vault: ChurchApp.Vault
end
