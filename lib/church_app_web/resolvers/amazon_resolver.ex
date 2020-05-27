defmodule ChurchAppWeb.Resolvers.AmazonResolver do
  alias ChurchApp.Utility

  def get_presigned_url(
        _,
        %{file_extension: file_extension, content_type: content_type, user_id: id},
        _
      ) do
    {:ok, presigned_url} = Utility.get_presigned_url(file_extension, content_type, id)
    {:ok, %{url: presigned_url}}
  end
end
