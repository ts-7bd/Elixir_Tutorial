defmodule Servy.Fetcher do
  #   def async(camera_name) do
  #     parent = self()
  #     spawn(fn -> send(parent, {:result, Servy.VideoCam.get_snapshot(camera_name)}) end)
  #   end

  def async(fun) do
    parent = self()
    spawn(fn -> send(parent, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    receive do
      {^pid, :result, value} -> value
    after 2000 ->
      raise "Timed out!"
    end
  end
end
