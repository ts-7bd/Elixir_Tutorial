defmodule Servy.Supervisor do

  use Supervisor

  def start_link do
    IO.inspect("Starting THE supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.KickStarter,
      Servy.ServicesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one) # one_for_all
  end
end

"""
{:ok, sup_pid} = Servy.Supervisor.start_link()
pid = Process.whereis(Servy.ServicesSupervisor)

Servy.ServicesSupervisor.child_spec([])
Servy.KickStarter.child_spec([])

Supervisor.which_children(sup_pid)
Servy.KickStarter.get_server() |> Process.exit(:kaboom)
Process.whereis(:pledge_server) |> Process.exit(:kaboom)

Supervisor.which_children(sup_pid)
Supervisor.which_children(pid)

pid = Process.whereis(Servy.ServicesSupervisor)
Process.exit(pid, :ojeoje) # does not restart the children of pid
Process.exit(pid, :kill) # now the child processes are restarted
pid = Process.whereis(Servy.ServicesSupervisor)
Supervisor.which_children(pid)
Process.whereis(Servy.ServicesSupervisor) |> Process.exit(:kill)

"""
