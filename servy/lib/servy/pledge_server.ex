defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # ======== Client interface functions

  def start_link(_arg) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged, 2000)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  @spec set_cache_size(any) :: :ok
  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  # ======== Server Callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "Can't touch this!")
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end

# ----------------------------------------------------------------------

"""

{:ok, pid}  = Servy.PledgeServer.start()

send(pid, {:stop, "hammertime"})

Servy.PledgeServer.set_cache_size(4)

Servy.PledgeServer.create_pledge("larry", 10)
Servy.PledgeServer.clear()
Servy.PledgeServer.create_pledge("moe", 20)
Servy.PledgeServer.create_pledge("curly", 30)
Servy.PledgeServer.create_pledge("daisy", 40)
Servy.PledgeServer.create_pledge("grace", 50)
Servy.PledgeServer.recent_pledges()
Servy.PledgeServer.total_pledged()
:sys.get_state(pid)

"""
