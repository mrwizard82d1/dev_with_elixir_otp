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

  # We plan to implement a new feature: setting the cache size. Currently,
  # The cache size is hard-coded to 3. We wish to change that to support
  # users changing the cache size during the running program.
  #
  # To implement this change, our state must change. Previously our state
  # wis simply a list of pledges. Now our state will need to include both
  # the list of pledges **and** the current cache size.
  #
  # We could define a new structure as a `Map` with two keys:
  # - `cache_size`
  # - `pledges`
  # However, this choice can easily become unwieldy. Instead, we will define
  # a `struct` to capture our state.
  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client Interface

  def start do
    # `GenServer` specifies name of server in trailing keyword list
    GenServer.start(__MODULE__, %State{}, name: @name)
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
  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
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
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    # We recurse with the existing state, the 3rd argument, but return
    # `state.pledges` back to the client.
    {:reply, state.pledges, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total =
      state.pledges
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

PledgeServer.clear

IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))

IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges(), label: "Recent pledges")

IO.inspect(PledgeServer.total_pledged(), label: "Total pledged")

IO.inspect(Process.info(pid, :messages))
