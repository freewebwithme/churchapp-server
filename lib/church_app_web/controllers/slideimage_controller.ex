defmodule ChurchAppWeb.SlideimageController do
  use ChurchAppWeb, :controller
  alias ChurchApp.Utility
  alias ChurchApp.Accounts

  def upload(
        conn,
        %{"image" => image, "userId" => user_id, "sliderNumber" => slider_number} = _params
      ) do
    file_ext = Utility.get_extension(image)
    {:ok, file_binary} = File.read(image.path)

    bucket_name = Utility.get_bucket_name()
    s3_filename = Utility.create_s3_file_name(file_ext, user_id)

    case Utility.upload_file_to_s3(bucket_name, s3_filename, file_binary) do
      %{status_code: 200} ->
        IO.puts("200 ok")
        slide_image_url = Utility.build_image_url(s3_filename)
        IO.puts("Printing slide_image_url")
        IO.inspect(slide_image_url)
        user = Accounts.get_user(user_id)

        cond do
          slider_number == "sliderOne" ->
            Accounts.update_church(user.church, %{slide_image_one: s3_filename})
            # Delete old slide image for saving s3 storage.
            image_key_name = user.church.slide_image_one

            case is_nil(image_key_name) do
              false ->
                Utility.delete_file_from_s3(bucket_name, image_key_name)

              _ ->
                nil
            end

          slider_number == "sliderTwo" ->
            Accounts.update_church(user.church, %{slide_image_two: s3_filename})
            # Delete old slide image for saving s3 storage.
            image_key_name = user.church.slide_image_two

            case is_nil(image_key_name) do
              false ->
                Utility.delete_file_from_s3(bucket_name, image_key_name)

              _ ->
                nil
            end

          slider_number == "sliderThree" ->
            Accounts.update_church(user.church, %{slide_image_three: s3_filename})
            # Delete old slide image for saving s3 storage.
            image_key_name = user.church.slide_image_three

            case is_nil(image_key_name) do
              false ->
                Utility.delete_file_from_s3(bucket_name, image_key_name)

              _ ->
                nil
            end

          true ->
            nil
        end

        conn
        |> send_resp(200, slide_image_url)

      %{status_code: 404} ->
        IO.puts("404 not found")
        send_resp(conn, 404, "업로드에 실패했습니다.") |> halt()

      %{status_code: 500} ->
        IO.puts("500 server error")
        send_resp(conn, 500, "업로드에 실패했습니다.") |> halt()
    end
  end
end
