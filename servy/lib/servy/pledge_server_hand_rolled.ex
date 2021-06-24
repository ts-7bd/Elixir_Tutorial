defmodule Servy.GenericServer do
  # Generic Client interface functions
  def start(callback_module, initial_state \\ [], name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    # if name in Process.registered(), do: Process.unregister(name)
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  # Generic Server Process (for example iex)
  def listen_loop(state, callback_module) do
    # here our callback module ist Servy.PledgeServerHandRolled
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      other ->
        new_state = callback_module.handle_info(other, state)
        listen_loop(new_state, callback_module)

    end
  end
end

# ----------------------------------------------------------------------
defmodule Servy.PledgeServerHandRolled do
  @name :pledge_server_hand_rolled

  alias Servy.GenericServer

  # Client interface functions

  def start do
    IO.puts("Starting the pledge server...")
    # telling which Module implements the callback module
    GenericServer.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  # Server Callbacks
  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_info(other, state) do
    IO.inspect(other, label: "Can't touch this!")
    state
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVERS
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# ----------------------------------------------------------------------

"""

pid = Servy.PledgeServerHandRolled.start()
send(pid, {:stop, "hammertime"})

Servy.PledgeServerHandRolled.create_pledge("larry", 10)
Servy.PledgeServerHandRolled.create_pledge("moe", 20)
Servy.PledgeServerHandRolled.create_pledge("curly", 30)
Servy.PledgeServerHandRolled.create_pledge("daisy", 40)
Servy.PledgeServerHandRolled.clear()

Servy.PledgeServerHandRolled.create_pledge("grace", 50)

Servy.PledgeServerHandRolled.recent_pledges()

Servy.PledgeServerHandRolled.total_pledged()

"""
