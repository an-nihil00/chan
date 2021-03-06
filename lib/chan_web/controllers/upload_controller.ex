defmodule ChanWeb.UploadController do
  use ChanWeb, :controller

  alias Chan.Repo
  alias Chan.Posts
  alias Chan.Posts.Upload

  def show(conn, %{"id" => id, "board_id" => board_id}) do
    case Repo.get(Upload, id, prefix: board_id) do
      nil ->
	text conn, "not found!"
      upload ->
	conn
	|> put_resp_header("Content-Type", upload.content_type)
	|> send_file(200, Upload.local_path(id, upload.filename))
    end
  end
end
