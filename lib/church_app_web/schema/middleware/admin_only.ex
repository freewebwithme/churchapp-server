defmodule ChurchAppWeb.Schema.Middleware.AdminOnly do
  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    case resolution.context do
      %{current_user: current_user} ->
        case current_user.admin do
          true ->
            resolution

          _ ->
            resolution
            |> Absinthe.Resolution.put_result({:error, "Access denied"})
        end

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Please Sign in first"})
    end
  end
end
