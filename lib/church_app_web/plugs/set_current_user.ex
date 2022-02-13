defmodule ChurchAppWeb.Plugs.SetCurrentUser do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    result = get_req_header(conn, "authorization")
    Absinthe.Plug.put_options(conn, context: context)
  end

  @max_age 35 * 24 * 365
  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{id: id}} <- ChurchAppWeb.AuthToken.verify(token, @max_age),
         %{} = user <- ChurchApp.Accounts.get_user(id) do
      IO.puts("User has bearer token in context")

      %{current_user: user}
    else
      _ ->
        IO.puts("Can't find bearer")
        %{}
    end
  end
end
