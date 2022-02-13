defmodule ChurchApp.Vault do
  @moduledoc """
  This module is for cloak ecto package
  This is used for encrypting various key value to database
  """
  use Cloak.Vault, otp_app: :church_app

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: decode_env!("CLOAK_KEY")}
      )

    {:ok, config}
  end

  defp decode_env!(cloak_key) do
    cloak_key
    |> System.get_env()
    |> Base.decode64!()
  end
end
