defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter
  @initial_state %{"/bigfoot" => 0, "/nessie" => 0}

  # Client interface
  def start do
    pid = spawn(__MODULE__, :listen_loop, [@initial_state])
    if @name not in Process.registered(), do: Process.register(pid, @name)
    pid
  end

  def bump_count(path) do
    send(@name, {self(), :bump_count, path})

    receive do {:response, state} -> state end
  end

  def get_count(path) do
    send(@name, {self(), :get_count, path})

    receive do {:response, count} -> count end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do {:response, counts} -> counts end
  end

  # Server interface
  def listen_loop(state) do
    receive do
      {sender, :bump_count, path} ->
        state = Map.update(state, path, 1, &(&1 + 1))
        send(sender, {:response, :ok})
        listen_loop(state)

      {sender, :get_count, path} ->
        send(sender, {:response, Map.get(state, path)})
        listen_loop(state)

      {sender, :get_counts} ->
        send(sender, {:response, state})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end
end

alias Servy.FourOhFourCounter, as: Counter

pid = Counter.start()
IO.inspect(pid)

path = "/bigfoot"
Counter.bump_count(path)
Counter.bump_count(path)
Counter.bump_count(path)
Counter.bump_count(path)
IO.inspect(Counter.get_count(path), label: "#{String.trim_leading(path, "/")}s")
