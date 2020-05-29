# IEx.configure colors: [enabled: true]
# IEx.configure colors: [ eval_result: [ :cyan, :bright ] ]
IO.puts(
  IO.ANSI.red_background() <>
    IO.ANSI.white() <> " ❄❄❄ No Other Name, Only Jesus ❄❄❄ " <> IO.ANSI.reset()
)

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  colors: [
    eval_result: [:green, :bright],
    eval_error: [[:red, :bright, "Bug Bug ..!!"]],
    eval_info: [:yellow, :bright]
  ],
  default_prompt:
    [
      # ANSI CHA, move cursor to column 1
      "\e[G",
      :white,
      "I",
      :red,
      # plain string
      "❤",
      :green,
      "%prefix",
      :white,
      "|",
      :blue,
      "%counter",
      :white,
      "|",
      :red,
      # plain string
      "▶",
      :white,
      # plain string
      "▶▶",
      # ❤ ❤-»" ,  # plain string
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)

alias ChurchApp.Repo
alias GoogleApi.YouTube.V3.Api
alias GoogleApi.YouTube.V3.Connection
alias ChurchApp.Api.YoutubeApi
alias ChurchApp.Youtube
alias ChurchApp.Videos.LatestVideos
alias ChurchApp.{Videos, Accounts}
alias ChurchApp.Accounts.{User, Employee, News}
alias ChurchApp.Utility

channel_id = "UC-R1QgG_g_hRrTsNxqyW1aw"
playlist_id = "PLdRZTYVWsX1jNZwuxNsENC6-J8kQv0sAy"
