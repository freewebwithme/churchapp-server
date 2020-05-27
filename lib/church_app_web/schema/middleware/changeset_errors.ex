defmodule ChurchAppWeb.Schema.Middleware.ChangesetErrors do
  @behaviour Absinthe.Middleware

  def call(res, _) do
    %{res | errors: Enum.flat_map(res.errors, &handle_error/1)}
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end

  defp handle_error(error), do: [error]
end
