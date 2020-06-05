defmodule ChurchApp.Utility do
  alias UUID
  alias Timex.Format.DateTime.Formatter
  alias ExAws.S3

  def create_id() do
    UUID.uuid1()
  end

  def format_datetime(datetime) do
    Formatter.format(datetime, "{YYYY}년 {M}월 {D}일")
  end

  @doc """
  Some of playlist has private video.
  Accessing thumbnails url like this
  video.snippet.thumbnails.medium.url will raise exception.
  If video is private video, then return default thumbnail url.
  """
  def get_thumbnail_url(video) do
    with true <- is_nil(video.snippet.thumbnails.medium) do
      "https://churchapp-la.s3-us-west-1.amazonaws.com/no-thumbnail.png"
    else
      false ->
        video.snippet.thumbnails.medium.url
    end
  end

  def get_extension(file) do
    file.filename |> Path.extname() |> String.downcase()
  end

  def get_bucket_name(), do: System.get_env("AWS_S3_BUCKET_NAME")

  def get_aws_s3_config() do
    ExAws.Config.new(:s3)
  end

  def create_s3_file_name(file_extension, user_id) do
    file_uuid = UUID.uuid4(:hex)
    s3_filename = "#{user_id}/#{file_uuid}#{file_extension}"
    s3_filename
  end

  def create_s3_file_name_for_employee(file_extension, church_id, employee_id) do
    file_uuid = UUID.uuid4(:hex)
    s3_filename = "#{church_id}/#{employee_id}/#{file_uuid}#{file_extension}"
    s3_filename
  end

  def build_image_url(filename) do
    bucket_name = get_bucket_name()
    region = System.get_env("AWS_REGION")
    "https://#{bucket_name}.s3-#{region}.amazonaws.com/#{filename}"
  end

  @doc """
  Uploading to S3
  """
  def get_presigned_url(file_extension, content_type, user_id) do
    config = get_aws_s3_config()
    bucket = get_bucket_name()
    filename = create_s3_file_name(file_extension, user_id)
    query_params = [{"Content-Type", content_type}]

    ExAws.S3.presigned_url(config, :put, bucket, filename, query_params: query_params)
  end

  def upload_file_to_s3(bucket_name, s3_filename, file_binary) do
    S3.put_object(bucket_name, s3_filename, file_binary, [{:acl, :public_read}])
    |> ExAws.request!()
  end

  def delete_file_from_s3(bucket_name, s3_filename) do
    S3.delete_object(bucket_name, s3_filename) |> ExAws.request!()
  end
end
