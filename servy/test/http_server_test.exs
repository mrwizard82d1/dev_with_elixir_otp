defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  @moduletag :capture_log

  doctest HttpServer

  test "module exists" do
    assert is_list(HttpServer.module_info())
  end

  test "accepts a request on a socket and sends back the respons" do
    spawn(HttpServer, :start, [test_port()])

    max_concurrent_requests = 5

    url = "http://localhost:4000/wildthings"

    1..max_concurrent_requests
    |> Enum.map(fn _ -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end

  defp test_port do
    4000
  end
end
