defmodule ChurchApp.Response.VideoSearchResponse do
  defstruct id: nil,
            etag: nil,
            next_page_token: nil,
            prev_page_token: nil,
            results_per_page: 0,
            total_results: 0,
            items: []
end
