defmodule ChurchAppWeb.PageController do
  use ChurchAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
