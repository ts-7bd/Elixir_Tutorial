defmodule Servy.Application do
  @moduledoc """
  the Application callback module
  """
  use Application

  def start(_type, _args) do
    IO.puts("Starting the application...")
    Servy.Supervisor.start_link()
  end
end
