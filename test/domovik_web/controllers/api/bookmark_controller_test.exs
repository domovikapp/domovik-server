defmodule DomovikWeb.Api.BookmarkControllerTest do
  use DomovikWeb.ConnCase

  alias Domovik.Users.User
  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Sync.Browser
  alias Domovik.Bookmarks
  alias Domovik.Bookmarks.Bookmark

  @browser_attrs %{name: "some name"}
  @basic_bookmark %{url: "http://pipo.com", title: "A Grand Website"}
  @invalid_bookmark %{url: "", title: ""}
  @invalid_attrs %{name: nil}
  @password "setup12341234"

  defp create_browser(%{conn: %Plug.Conn{assigns: %{current_user: user}}}) do
    browser = fixture(:browser, user)
    %{browser: browser}
  end

  defp assign_user(%{conn: conn}) do
    user =
      %User{}
      |> User.changeset(%{
        email: "test@example.com",
        password: @password,
        password_confirmation: @password
      })
      |> Repo.insert!()

    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :domovik)
    {:ok, conn: conn}
  end

  def fixture(:browser, user) do
    {:ok, browser} = Sync.create_browser(user, @browser_attrs)

    browser
  end

  def fixture(:bookmark, user, browser) do
    Bookmarks.create_bookmark(user, browser, @basic_bookmark)
  end

  describe "index" do
    setup [:assign_user]

    test "lists all bookmarks", %{conn: conn} do
      conn = get(conn, Routes.api_browser_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create a single bookmark" do
    setup [:assign_user, :create_browser]

    test "when data is valid", %{conn: conn, browser: browser} do
      conn1 =
        post(conn, Routes.api_bookmarks_path(conn, :create, %{
          "bookmark" => @basic_bookmark,
          "uuid" => browser.uuid
        }))


      assert bm = %{"title" => "A Grand Website"} = json_response(conn1, 201)["data"]
    end
    test "when data is invalid", %{conn: conn} do
      user = conn.assigns.current_user
      browser = fixture(:browser, user)

      conn1 =
        post(conn, Routes.api_bookmarks_path(conn, :create, %{
          "bookmark" => @invalid_bookmark,
          "uuid" => browser.uuid
        }))


      assert json_response(conn1, 422)["errors"] != %{}
    end
  end

  describe "delete bookmarks" do
    setup [:assign_user, :create_browser]

    test "deletes chosen bookmark", %{conn: conn, browser: browser} do
      conn1 =
        post(conn, Routes.api_bookmarks_path(conn, :create, %{
          "bookmark" => @basic_bookmark,
          "uuid" => browser.uuid
        }))
      assert bm = %{"title" => "A Grand Website"} = json_response(conn1, 201)["data"]

      conn1 = delete(conn, Routes.api_bookmarks_path(conn, :delete, bm["id"]))
      assert response(conn1, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_bookmarks_path(conn, :show, bm["id"]))
      end
    end
  end
end
