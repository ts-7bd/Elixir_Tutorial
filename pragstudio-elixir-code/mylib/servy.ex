defmodule(Servy) do
  def hello(name) do
    "Howdy, #{name}!"
  end
end

IO.puts Servy.hello("Elixir")


# start new project
#bash> mix new servy
#bash> cd servy
#bash> mix test
#bash> mix help
# run and compile program
#bash> iex servy.ex
#iex> c "servy.ex" <-- compile within iex
#iex> r Servy  <-- after changes in the submodule
#iex> String.reverse("kep")
#iex> 2+1
#iex>  Servy.hello("Tommy")
