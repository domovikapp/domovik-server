defmodule DomovikWeb.BrowserControllerTest do
  use DomovikWeb.ConnCase

  alias Domovik.Repo
  alias Domovik.Sync
  alias Domovik.Users.User

  @password "secret1234"

  @create_attrs %{name: "TestBrowser"}

  def fixture(:browser, user) do
    {:ok, browser} = Sync.create_browser(user, @create_attrs)
    browser
  end

  describe "unlogged" do
    test "redirect to home page when not logged in", %{conn: conn} do
      conn = get(conn, Routes.browser_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "logged" do
    setup [:assign_user, :create_browser]

    test "list browsers", %{conn: conn} do
      conn = get(conn, Routes.browser_path(conn, :index))
      assert html_response(conn, 200) =~ "TestBrowser"
    end
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

  defp create_browser(%{conn: %Plug.Conn{assigns: %{current_user: user}}}) do
    browser = fixture(:browser, user)
    %{browser: browser}
  end
end
