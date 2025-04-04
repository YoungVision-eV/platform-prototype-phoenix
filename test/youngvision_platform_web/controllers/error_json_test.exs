defmodule YoungvisionPlatformWeb.ErrorJSONTest do
  use YoungvisionPlatformWeb.ConnCase, async: true

  test "renders 404" do
    assert YoungvisionPlatformWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert YoungvisionPlatformWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
