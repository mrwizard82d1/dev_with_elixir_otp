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

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  # Server Callbacks

  # Implement the `GenServer.init/1` callback
  #
  # Remember that `start/0` **blocks** until this call returns. Therefore,
  # be brief!
  def init(start_state) do
    start_pledges = fetch_recent_pledges_from_service()
    new_state = %{start_state | pledges: start_pledges}
    {:ok, new_state}
  end

  # The requirements of `GenServer.handle_cast` are slightly different than
  # our original requirements. We must return a tuple of two items. The
  # first item is the atom `:noreply`. The second item is our new state.
  #
  # Note that atoms other than `:noreply` are possible; however, `:noreply`
  # is by far the most used.
  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
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

  def handle_info(message, state) do
    # Handle various messages (we do not)
    IO.puts("Can't touch this! #{inspect(message)}")

    # Return the (unchanged) `state`
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service() do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value
    [{"wilma", 15}, {"fred", 25}]
  end
end

alias Servy.PledgeServer

# The last change required by `GenServer` is when we start the server.
# `GenServer.start/0` returns a value that is a tuple; typically, a tuple
# like `{:ok, pid}`.
{:ok, pid} = PledgeServer.start()

send(pid, {:stop, "hammertime"})

PledgeServer.set_cache_size(4)

IO.inspect(PledgeServer.create_pledge("larry", 10))

# PledgeServer.clear

# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))

IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges(), label: "Recent pledges")

IO.inspect(PledgeServer.total_pledged(), label: "Total pledged")

IO.inspect(Process.info(pid, :messages))
