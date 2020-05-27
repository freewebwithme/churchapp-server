defmodule ChurchAppWeb.Plugs.SetCurrentUser do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    result = get_req_header(conn, "authorization")
    IO.puts("Printing authorization header")
    IO.inspect(result)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{id: id}} <- ChurchAppWeb.AuthToken.verify(token),
         %{} = user <- ChurchApp.Accounts.get_user(id) do
      IO.puts("User has bearer token in context")
      user2 = ChurchApp.Accounts.get_user(5)
      IO.inspect(user2)
      IO.inspect(token)

      %{current_user: user}
    else
      _ ->
        IO.puts("Can't find bearer")
        %{}
    end
  end
end
