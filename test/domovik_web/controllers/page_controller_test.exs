defmodule DomovikWeb.PageControllerTest do
  use DomovikWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/session/new")
    assert html = html_response(conn, 200)
    assert html =~ Routes.pow_session_path(conn, :create)
    refute html =~ "request_path="
    assert html =~ "<label for=\"user_email\">Email</label>"
    assert html =~ "<input autofocus id=\"user_email\" name=\"user[email]\" type=\"email\">"
    assert html =~ "<input id=\"user_password\" name=\"user[password]\" type=\"hidden\">"
    assert html =~ "<label for=\"user_passphrase\">Password</label>"
    assert html =~ "<input id=\"user_passphrase\" name=\"\" type=\"password\">"
    assert html =~ "<a href=\"/registration/new\">Create an Account</a>"
  end
end
