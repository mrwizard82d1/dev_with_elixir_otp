defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  @moduletag :capture_log

  doctest HttpServer

  test "module exists" do
    assert is_list(HttpServer.module_info())
  end
end
