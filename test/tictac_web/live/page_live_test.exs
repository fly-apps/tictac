defmodule TictacWeb.PageLiveTest do
  use TictacWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Player Settings"
    assert render(page_live) =~ "Player Settings"
  end
end
