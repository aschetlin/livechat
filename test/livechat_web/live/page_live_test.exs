defmodule LivechatWeb.PageLiveTest do
  use LivechatWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Join random room"
    assert render(page_live) =~ "Join random room"
  end
end
