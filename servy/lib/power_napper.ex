power_nap = fn ->
  time = :rand.uniform(10_000)
  :timer.sleep(time)
  time
end

parent = self()
spawn(fn -> send(parent, {:slept, power_nap.()}) end)

receive do
  {:slept, time_slept} -> IO.puts("Slept #{time_slept} ms")
end
