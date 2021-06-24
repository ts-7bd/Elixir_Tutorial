defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  use GenServer

  # Client interface

  def start do
    IO.puts("Starting the 404 counter...")
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def bump_count(path) do
    GenServer.call(@name, {:bump_count, path})
  end

  def get_counts do
    GenServer.call(@name, :get_counts)
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def reset do
    GenServer.cast(@name, :reset)
  end

  # Server Callbacks

  def init(state) do
    new_state = Map.update(state, "trolls", 4500, fn x -> x end)
    {:ok, new_state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "Can't touch this!")
    {:noreply, state}
  end
end

"""
alias Servy.FourOhFourCounter, as: Counter

{:ok, pid} = Counter.start()

send(pid, {:stop, "hammertime"})
send(pid, {:call, self(), {:bump_count, "/sheep"}})

for _x <- 1..10, do: Counter.bump_count("/bigfoot")
1..500 |> Enum.each(fn _x -> Counter.bump_count("/aliens") end)

Counter.get_count("/bigfoot")

Counter.get_counts()


Counter.reset()
Counter.get_counts()


"""
