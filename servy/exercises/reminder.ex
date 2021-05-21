defmodule Timer do

  def remind(string,seconds) do
    ms = seconds * 1000
    spawn(fn -> :timer.sleep(ms); IO.puts "#{string}\n" end)
  end

end

Timer.remind("Stand Up", 5)
Timer.remind("Sit Down", 10)
Timer.remind("Fight, Fight, Fight", 15)

"""
execute with: elixir --no-halt reminder.ex
to tell the elixir executable to not exit the Erlang VM
"""
