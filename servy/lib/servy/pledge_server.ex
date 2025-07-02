# NOTE: When we run this code in `iex`, the Elixir runtime presents a
# warning that we **did not** define the function `init/1` which the
# warning reports is **required** by the behaviour GenServer. However,
# the runtime helpfully, injects a default implementation for us.
#
# ```
# def init(init_arg) do
#   {:ok, init_arg}
# end
# ```
defmodule Servy.PledgeServer do
  @name :pledge_server

  # The `use` macro injects default implementations of required callbacks
  # into the current module. Our implementations of `handle_call` and
  # `handle_cast` will override these two injected callbacks.
  use GenServer

  # Client Interface

  def start do
    # `GenServer` specifies name of server in trailing keyword list
    GenServer.start(__MODULE__, [], name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@name, :total_pledged)
  end

  def clear() do
    GenServer.cast(@name, :clear)
  end

  # Server Callbacks

  # The requirements of `GenServer.handle_cast` are slightly different than
  # our original requirements. We must return a tuple of two items. The
  # first item is the atom `:noreply`. The second item is our new state.
  #
  # Note that atoms other than `:noreply` are possible; however, `:noreply`
  # is by far the most used.
  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  # `GenServer.handle_call` requires that we return a tuple which we
  # already return; however, it requires that the tuple contain a tag,
  # `:reply` as the first item.
  #
  # This keyword instructs the `GenServer` to reply back to the client.
  # The reply to the client will contain the remaining items in the tuple.
  #
  # In addition, `GenServer.handle_call` takes **three** arguments not
  # **two** as we supply. We will name the additional value `from`. This
  # second argument is to contain additional information about the
  # **sender**. However, this information about the sender is typically
  # **not needed**. Consequently, we will ignore it in this code.
  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {:reply, id, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total =
      state
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
    {:reply, total, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

# The last change required by `GenServer` is when we start the server.
# `GenServer.start/0` returns a value that is a tuple; typically, a tuple
# like `{:ok, pid}`.
{:ok, pid} = PledgeServer.start()

# send(pid, {:stop, "hammertime"})

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))

# PledgeServer.clear

IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges(), label: "Recent pledges")

IO.inspect(PledgeServer.total_pledged(), label: "Total pledged")

IO.inspect(Process.info(pid, :messages))
