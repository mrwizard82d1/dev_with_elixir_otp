defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  @moduletag :capture_log

  doctest HttpServer

  test "module exists" do
    assert is_list(HttpServer.module_info())
  end

  test "accepts a request on a socket and sends back the respons" do
    spawn(HttpServer, :start, [test_port()])

    parent = self()

    max_concurrent_requests = 5

    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        result = HTTPoison.get("http://localhost:4000/wildthings")
        send(parent, result)
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, %{status_code: status_code, body: body}} ->
          assert status_code == 200
          assert body = "Bears, Lions, Tigers"

        unexpected ->
          assert false, "Unexpected #{unexpected}"
      end
    end
  end

  defp test_port do
    4000
  end
end
