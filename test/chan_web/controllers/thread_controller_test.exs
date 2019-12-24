defmodule ChanWeb.ThreadControllerTest do
  use ChanWeb.ConnCase

  alias Chan.Threads
  alias Chan.Threads.Thread

  @create_attrs %{
    subject: "some subject"
  }
  @update_attrs %{
    subject: "some updated subject"
  }
  @invalid_attrs %{subject: nil}

  def fixture(:thread) do
    {:ok, thread} = Threads.create_thread(@create_attrs)
    thread
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all threads", %{conn: conn} do
      conn = get(conn, Routes.thread_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create thread" do
    test "renders thread when data is valid", %{conn: conn} do
      conn = post(conn, Routes.thread_path(conn, :create), thread: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.thread_path(conn, :show, id))

      assert %{
               "id" => id,
               "subject" => "some subject"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.thread_path(conn, :create), thread: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update thread" do
    setup [:create_thread]

    test "renders thread when data is valid", %{conn: conn, thread: %Thread{id: id} = thread} do
      conn = put(conn, Routes.thread_path(conn, :update, thread), thread: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.thread_path(conn, :show, id))

      assert %{
               "id" => id,
               "subject" => "some updated subject"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, thread: thread} do
      conn = put(conn, Routes.thread_path(conn, :update, thread), thread: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete thread" do
    setup [:create_thread]

    test "deletes chosen thread", %{conn: conn, thread: thread} do
      conn = delete(conn, Routes.thread_path(conn, :delete, thread))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.thread_path(conn, :show, thread))
      end
    end
  end

  defp create_thread(_) do
    thread = fixture(:thread)
    {:ok, thread: thread}
  end
end
