defmodule Servy.HttpClient do
  def send_request(request) do
    # to make it runnable on one machine
    some_host_in_net = ~c"localhost"

    {:ok, socket} =
      :gen_tcp.connect(some_host_in_net, 4000, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    response
  end
end

# request = """
# GET /bears HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0/r
# Accept: */*\r
# \r
# """

# spawn(fn -> Servy.HttpServer.start(4000) end)

# response = Servy.HttpClient.send_request(request)
# IO.puts(response)
