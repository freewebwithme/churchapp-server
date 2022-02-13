defmodule ChurchAppWeb.ProfileImageUploadController do
  use ChurchAppWeb, :controller
  alias ChurchApp.Utility
  alias ChurchApp.Accounts

  def upload(
        conn,
        %{"image" => image, "churchId" => church_id, "employeeId" => employee_id} = _params
      ) do
    # upload to Amazon s3
    file_ext = Utility.get_extension(image)
    {:ok, file_binary} = File.read(image.path)

    bucket_name = Utility.get_bucket_name()
    s3_filename = Utility.create_s3_file_name_for_employee(file_ext, church_id, employee_id)

    case Utility.upload_file_to_s3(bucket_name, s3_filename, file_binary) do
      %{status_code: 200} ->
        # Success
        profile_image_url = Utility.build_image_url(s3_filename)
        IO.puts("Printing profile_image_url #{profile_image_url}")

        employee = Accounts.get_employee_by_id(church_id, employee_id)
        default_image = "default-avatar.jpg"

        case default_image == employee.profile_image do
          true ->
            # Employee was using default image, so skip delete image file from S3
            Accounts.update_employee_profile_image(employee, s3_filename)

          _ ->
            # Delete old image file, so keep just one profile image
            Utility.delete_file_from_s3(bucket_name, employee.profile_image)
            Accounts.update_employee_profile_image(employee, s3_filename)
        end

        conn |> send_resp(200, profile_image_url)
    end
  end
end
