defmodule Servy.PledgeServer do
  @name :pledge_server

  # Client interface functions

  def start(initial_state \\ []) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    IO.inspect(pid, label: "Starting the pledge server")
    if @name in Process.registered(), do: Process.unregister(@name)
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send(@name, {self(), :create_pledge, name, amount})

    receive do {:response, status} -> status end
  end

  def recent_pledges do
    send(@name, {self(), :recent_pledges})

    receive do {:response, pledges} -> pledges end
  end

  def total_pledged do
    send(@name, {self(), :total_pledged})

    receive do {:response, total} -> total end
  end

  # runs on the Server (for example iex)

  def listen_loop(state) do
    # IO.puts "\nWaiting for a message..."
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        #    IO.puts "#{name} pledge #{amount}"
        #    IO.inspect(new_state, label: "New state is")
        send(sender, {:response, id})
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        IO.inspect(sender, label: "sent pledges  to")
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVERS
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start()
send pid, {:stop, "hammertime"}

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))
IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())


# receive do
#   {:response, pledges} -> IO.inspect(pledges)
# end
