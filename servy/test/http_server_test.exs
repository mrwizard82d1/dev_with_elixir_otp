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

    urls = [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/bigfoot",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/bigfoot",
      "http://localhost:4000/wildthings"
    ]

    status_codes = [200, 404, 200, 404, 200]

    bodies = [
      "Bears, Lions, Tigers",
      "No /bigfoot here!",
      "Bears, Lions, Tigers",
      "No /bigfoot here!",
      "Bears, Lions, Tigers"
    ]

    for {url, status_code, body} <- Enum.zip([urls, status_codes, bodies]),
        do: test_one(url, status_code, body)
  end

  def test_one(url, status_code, body) do
    Task.async(fn -> HTTPoison.get(url) end)
    |> Task.await()
    |> assert_successful_response(status_code, body)
  end

  defp assert_successful_response({:ok, response}, status_code, body) do
    assert response.status_code == status_code
    assert response.body == body
  end

  defp test_port do
    4000
  end
end
