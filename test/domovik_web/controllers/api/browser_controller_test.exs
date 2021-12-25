defmodule DomovikWeb.Api.BrowserControllerTest do
  use DomovikWeb.ConnCase

  alias Domovik.Users.User
  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Sync.Browser

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  @password "setup12341234"
  @valid_params %{"user" => %{"email" => "test@example.com", "password" => @password}}

  defp create_browser(%{conn: %Plug.Conn{assigns: %{current_user: user}}}) do
    browser = fixture(:browser, user)
    %{browser: browser}
  end

  defp assign_user(%{conn: conn}) do
    user = %User{}
    |> User.changeset(%{email: "test@example.com", password: @password, password_confirmation: @password})
    |> Repo.insert!()

    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :domovik)
    {:ok, conn: conn}
  end

  def fixture(:browser, user) do
    {:ok, browser} = Sync.create_browser(user, @create_attrs)

    browser
  end

  describe "index" do
    setup [:assign_user]

    test "lists all browsers", %{conn: conn} do
      conn = get(conn, Routes.api_browser_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create browser" do
    setup [:assign_user]

    test "renders browser when data is valid", %{conn: conn} do
      conn1 = post(conn, Routes.api_browser_path(conn, :create), @create_attrs)
      assert %{"uuid" => id} = json_response(conn1, 201)["data"]

      conn2 = get(conn, Routes.api_browser_path(conn, :show, id))
      assert %{"name" => "some name"} = json_response(conn2, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_browser_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update browser" do
    setup [:assign_user, :create_browser]

    test "renders browser when data is valid", %{conn: conn, browser: %Browser{uuid: id} = browser} do
      conn1 = put(conn, Routes.api_browser_path(conn, :update, browser.uuid), %{name: "NEW NAME"})
      assert %{"uuid" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get(conn, Routes.api_browser_path(conn, :show, id))
      assert %{"name" => "NEW NAME"} = json_response(conn2, 200)["data"]
    end

  end

  describe "delete browser" do
    setup [:assign_user, :create_browser]

    test "deletes chosen browser", %{conn: conn, browser: browser} do
      conn1 = delete(conn, Routes.api_browser_path(conn, :delete, browser))
      assert response(conn1, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_browser_path(conn, :show, browser))
      end
    end
  end
end
