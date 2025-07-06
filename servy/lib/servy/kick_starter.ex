defmodule Servy.KickStarter do
  use GenServer

  def start do
    IO.puts "Starting the kickstarter..."

    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # By setting the `:trap_exit` flag to `true`, the `KickStarter`
    # process will **not** crash when the `HttpServer` process dies.
    # (I'm currently uncertain how to kill this process if I so choose -
    # other than by restarting `iex` or the elikir OS process running
    # the erlang VM.
    Process.flag(:trap_exit, true)

    IO.puts "Starting the HTTP server...."

    server_pid = spawn(Servy.HttpServer, :start, [4000])

    # By linking the `HttpServer`, this process can "control" the
    # HttpServer (Elixir) process. This linkage allows the KickStarter
    # process to be notified if the `HttpServer` process dies and to
    # respond appropriately.
    #
    # Note that the link is **bidirectional**; that is, this process
    # is linked the `HttpServer` process **and** thee `HttpServer`
    # process is linked to this, the `KickStarter`, process.
    #
    # Because the link is bidirectional and because the termination reason
    # is "abnormal," when we kill the `HttpServer` process, the `KickStarter`
    # process **dies as well**.
    Process.link(server_pid)

    Process.register(server_pid, :http_server)
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    # In production code one probably wants to log information about this
    # terminated process. We, however, wil simply print a message out to
    # the console.
    IO.puts("HttpServer exited (#{inspect reason})")

    IO.puts("(Re-)Starting the HttpServer")
    server_pid = spawn(Servy.HttpServer, :start, [4000])
    Process.link(server_pid)
    Process.register(server_pid, :http_server)
    {:noreply, server_pid}
  end
end
