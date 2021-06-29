defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer
  # use GenServer, start: {__MODULE__, :start_link, [60]}, restart: :temporary

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end

  def child_spec(:frequent) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[interval: 1, target: nil]]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def child_spec(:infrequent) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[interval: 60, target: "bears/1"]]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  # Client Interface

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(options) do
    interval = Keyword.get(options, :interval)
    target = Keyword.get(options, :target)
    IO.puts("Starting the sensor server with #{interval} min refresh...")
    IO.inspect(target, label: "Viewing")
    initial_state = %State{refresh_interval: :timer.minutes(interval)}
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    IO.inspect(%State{})
    GenServer.call(@name, :get_sensor_data)
  end

  def get_refresh_interval() do
    GenServer.call(@name, :get_refresh_interval)
  end

  def set_refresh_interval(time_in_ms) do
    GenServer.cast(@name, {:set_refresh_interval, time_in_ms})
  end

  # Server Callbacks

  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    initial_state = %{state | sensor_data: sensor_data}
    schedule_refresh(state.refresh_interval)
    {:ok, initial_state}
  end

  def handle_cast({:set_refresh_interval, time_in_ms}, state) do
    new_state = %{state | refresh_interval: time_in_ms}
    {:noreply, new_state}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %{state | sensor_data: sensor_data}
    IO.inspect(new_state.sensor_data.snapshots, label: "recent snapshots")
    #IO.inspect(Map.get(new_state, :snapshots), label: "snapshots")
    schedule_refresh(state.refresh_interval)
    {:noreply, new_state}
  end

  defp schedule_refresh(time_in_ms) do
    Process.send_after(self(), :refresh, time_in_ms)
  end

  def handle_call(:get_refresh_interval, _from, state) do
    {:reply, state.refresh_interval, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end

"""
{:ok, sup_pid} = Servy.Supervisor.start_link()
sensor_pid = Process.whereis(:sensor_server)
%Servy.SensorServer.State{}
Servy.SensorServer.set_refresh_interval(10000)

"""
