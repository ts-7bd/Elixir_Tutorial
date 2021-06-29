defmodule Servy.KickStarter do
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

  # ======== Client interface functions

  def start_link(_arg) do
    IO.puts("Starting the kickstarter...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # if you register the server process as :http_server
  # def get_server() do
  #   GenServer.call(__MODULE__, :http_server)
  # end

  def get_server do
    GenServer.call __MODULE__, :get_server
  end


  # ======== Server callbacks

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  # if you register the server process as :http_server
  # def handle_call(:http_server, _from, state) do
  #   server_pid = Process.whereis(:http_server)
  #   {:reply, server_pid, state}
  # end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited #{reason}")
    server_pid = start_server()
    {:noreply, server_pid}
  end

   defp start_server do
    IO.puts("Starting the HTTP Server...")
    # server_pid = spawn(Servy.HttpServer, :start, [4000])
    # Process.link(server_pid)
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    # Process.register(server_pid, :http_server)
    server_pid
   end

end

"""
{:ok, kick_pid} = Servy.KickStarter.start
server_pid = Servy.KickStarter.get_server

# server_pid = Process.whereis(:http_server)
Process.info(server_pid, :links)
Process.info(kick_pid, :links)

Process.exit(server_pid, :kaboom)
Process.alive?(server_pid)
Process.alive?(kick_pid)

"""
