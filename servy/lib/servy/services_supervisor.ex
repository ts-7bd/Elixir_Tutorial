defmodule Servy.ServicesSupervisor do

  use Supervisor

  def start_link(_args) do
    IO.inspect("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      Servy.FourOhFourCounter,
      #{Servy.SensorServer, :frequent}
      # {Servy.SensorServer, :infrequent}
      {Servy.SensorServer, interval: 10, target: "bigfoot"}
      # %{
      #   id: Servy.SensorServer,
      #   start: {Servy.SensorServer, :start_link, [[interval: 60, target: "bigfoot"]]}
      # }
    ]

    opts = [strategy: :one_for_one, max_restarts: 5, max_seconds: 10]

    Supervisor.init(children, opts)
  end

end


"""
{:ok, sup_pid} = Servy.ServicesSupervisor.start_link([])
Supervisor.which_children(sup_pid)
Supervisor.count_children(sup_pid)
Process.whereis(:sensor_server) |> Process.exit(:daswarwohlnix)
Process.whereis(:pledge_server) |> Process.exit(:daswarwohlnix)

Supervisor.terminate_child(sup_pid, Servy.PledgeServer)
Supervisor.restart_child(sup_pid, Servy.PledgeServer)


Servy.PledgeServer.child_spec([])

Ausgabe im Pragmatic Studio:
%{id: Servy.PledgeServer,
  restart: :permanent,
  shutsown: 5000,
  start: {Servy.PledgeServer, :start_link, [[]]}},
  type: :worker}

Ausgabe jetzt:
%{id: Servy.PledgeServer,
  start: {Servy.PledgeServer, :start_link, [[]]}}


"""
