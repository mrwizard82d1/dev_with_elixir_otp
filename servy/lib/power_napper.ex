defmodule PowerMapper do
  def power_nap() do
    time = :rand.uniform(10_000)
    :timer.sleep(time)
    time
  end
end

parent = self()
spawn(fn -> send(parent, {:slept, PowerMapper.power_nap()}) end)

receive do
  {:slept, time_slept} -> IO.puts("Slept #{time_slept} ms")
end
