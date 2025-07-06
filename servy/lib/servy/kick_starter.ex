defmodule Servy.KickStarter do
  use GenServer

  # Client interface

  def start_link(_unused) do
    IO.puts "Starting the kickstarter..."

    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_server do
    GenServer.call __MODULE__, :get_server
  end

  # Server Callbacks

  def init(:ok) do
    # By setting the `:trap_exit` flag to `true`, the `KickStarter`
    # process will **not** crash when the `HttpServer` process dies.
    # (I'm currently uncertain how to kill this process if I so choose -
    # other than by restarting `iex` or the elikir OS process running
    # the erlang VM.
    Process.flag(:trap_exit, true)

    server_pid = start_http_server()

    {:ok, server_pid}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    # In production code one probably wants to log information about this
    # terminated process. We, however, wil simply print a message out to
    # the console.
    IO.puts("HttpServer exited (#{inspect reason})")

    server_pid = start_http_server()
    {:noreply, server_pid}
  end

  defp start_http_server() do
    IO.puts("Starting the HttpServer....")
    # Perform spawn and link in one atomic step
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
  end
end
