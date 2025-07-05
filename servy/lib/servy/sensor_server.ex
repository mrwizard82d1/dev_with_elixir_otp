defmodule Servy.SensorServer do
  @name :sensor_server
  # Five seconds for testing; 60 minutes in production
  @refresh_interval :timer.seconds(5)

  use GenServer

  # Convert @refresh_interval to State
  #
  # Five seconds for testing; 60 minutes in production
  defmodule State do
    defstruct snapshots: [], location: %{}, refresh_interval: :timer.seconds(5)
  end

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data() do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(new_interval) do
    GenServer.cast(@name, {:set_refresh_interval, new_interval})
  end

  # Server Callbacks

  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %State{
      state |
      snapshots: sensor_data.snapshots,
      location: sensor_data.location,
    }
    schedule_refresh()
    {:ok, new_state}
  end

  def handle_info(:refresh, _state) do
    IO.puts("Refreshing the cache...")

    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts("Can't touch this! #{inspect unexpected}")

    {:noreply, state}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_sensor_data() do
    IO.puts("Running tasks to get sensor data")

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end

  def handle_cast({:set_refresh_interval, new_interval}, state) do
    IO.puts("Called handle_cast with :set_refresh_interval #{new_interval}")
    {:noreply, state}
  end
end
