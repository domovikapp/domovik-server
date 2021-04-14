defmodule DomovikWeb.PageControllerTest do
  use DomovikWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "A cross-browser synchronization service"
  end
end
