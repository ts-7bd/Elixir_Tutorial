defmodule Power do

  def nap() do

    power_nap = fn ->
      time = :rand.uniform(10_000)
      :timer.sleep(time)
      time
    end

    parent = self()
    spawn(fn -> send(parent, {:message, power_nap.()}) end)
    receive do
      {:message, time} -> "Slept #{time}ms!"
    end

  end
end

IO.inspect(Power.nap)
