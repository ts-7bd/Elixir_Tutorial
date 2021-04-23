defmodule LearnElixir do
  @moduledoc """
  Documentation for `LearnElixir`.
  """

  @doc """
  ----------------- Nützliche Kürzel
  CNTRL + SHIFT + P  # Befehle suchen
  SHIFT + ALT + F # Auto Formatierung
  """


# start new project
#bash> mix new learn_elixir
#bash> cd learn_elixir
#bash> mix test
#bash> mix help
#bash> iex -S mix
# run and compile program
#bash> iex servy.ex
#iex> c "servy.ex" <-- compile within iex
#iex> r Servy  <-- after changes in the submodule
#iex> String.reverse("kep")
#iex> 2+1
#iex>  Servy.hello("Tommy")

# High level transformations
# h String.<tab> --> help with ooptions
# lines = String.split(request,"\n")
#iex> first_line = List.first(lines)
#iex> first_line = request |> String.split("\n") |> List.first
#iex> parts = String.split(first_line,"/")
#iex> Enum.at(lines,3)
#iex> Enum.at(parts,0)

# Pattern Matcher
#iex> a = 1
#iex> 1 = a
#iex> 2 = a --> Match Eroor
#iex> ^a = 34 --> Match Error
#iex> [first, 3, 5] = [11, 3, 5]
#iex> first
#iex> [match, path, version] = String.split(first_line," ")
#iex> version

# defining maps with atoms or string as keys
# keys are assinged to values by arrows and colons
#iex> m = %{ method: "GET", path: "/wildthings", resp_body: " " } # atoms as keys
#iex> m[:method] or m.method
#iex> m = %{ "method" => "GET", "path" => "/wildthings" }  # string as keys
#iex> m["method"]
#iex> f = %{ a: 1, b: 'asdf', c: [34.4,18.1,24.8] }
#iex> f.c

# infos about Map function and change Map values
#iex> h Map.put
#iex> conv = %{ method: "GET", path: "/wildthings"}
#iex> conv = Map.put(conv, :resp_body, "bears")
#iex> conv = %{conv | resp_body: "Bears, Lions, Tigers"}

#iex> conv = %{ method: "GET", path: "/wildthings" }
#iex> conv.method or conv[:method]
#iex> conv = %{ "method" => "GET", "path" => "/wildthings" }
#iex> cconv["method"]
#iex> conv[:method] --> nil
#iex> conv.method --> KeyError

#iex> resp_body = "Bears, Lions, Tigers, Elephants"
#iex> String.length(resp_body)
#iex> byte_size(resp_body)


# pattern match and how to make bears = bears/1
#iex> "bears/" <> "1555" -> bears/1555
#iex> "bears/" <> id = "bears/1" -> id = 1


"""
iex(38)> [a,b | rest] = [1,2,3,4,5,6,73,8,45,12,663,9,10,12,88]
[1, 2, 3, 4, 5, 6, 73, 8, 45, 12, 663, 9, 10, 12, 88]
iex(39)> a
1
iex(40)> b
2
iex(42)> rest
[3, 4, 5, 6, 73, 8, 45, 12, 663, 9, 10, 12, 88]
iex(47)> list = [{:a, 1}, {:b, 2}]
[a: 1, b: 2]
iex(53)> list = list ++ [c: 3]
[a: 1, b: 2, c: 3]
iex(55)> list[:a]
1
iex(56)> list = [a: 0] ++ list
[a: 0, a: 1, b: 2, c: 3]
iex(62)> list
[a: 0, a: 1, b: 2, c: 3]
iex(63)> Enum.fetch(rest,2)
{:ok, 5}
iex(70)> Enum.sort(list)
[a: 0, a: 1, b: 2, c: 3]
iex(71)> Enum.sort(rest)
[3, 4, 5, 6, 8, 9, 10, 12, 12, 45, 73, 88, 663]
iex(72)> Enum.with_index(rest,3)
iex(76)> Enum.min_max(rest)
{3, 663}
iex(77)> Enum.fetch(list,0)
{:ok, {:a, 0}}
iex(78)> Enum.fetch(rest,0)
{:ok, 3}
iex(81)> Enum.take(rest,8)
[3, 4, 5, 6, 73, 8, 45, 12]


# Pattern matching with Regular Expression
path = "/bears?id=1"
regex = ~r{\/(\w+)\?id=(\d+)}
Regex.match?(regex, path)
# regex fits also to i.e. "lions?id=790"

# writes name and index of an expression into the map wildthing
regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
wildthing = Regex.named_captures(regex, "/lions?id=10231")

# use Logger to write formatted messages
require Logger
Logger.info "It's lunchtime somewhere."
Logger.warn "Do we have a problem, Houston?"
Logger.error "Space shuttle is lost!"
Logger.debug "Strange things are happening."
# further information on Logger
h Logger
• :emergency - when system is unusable, panics
• :alert - for alerts, actions that must be taken immediately, ex.  corrupted database
• :critical - for critical conditions
• :error - for errors
• :warning - for warnings
• :notice - for normal, but significant, messages
• :info - for information of any kind
• :debug - for debug-related messages

???
iex(26)> wildthing
%{"id" => "10231", "thing" => "lions"}
iex(27)> wildthing2
%{id: "10231", thing: "lions"}

# structures and maps
defmodule Servy.Conv do
  defstruct method: "", path: "", resp_body: "", status: nil
end
conv = %Servy.Conv{method: "GET", status: 403}
%{conv | status: 500}
conv.method
%{method: "GET"} = conv
%Servy.Conv{method: "GET"} = conv
map = %{method: "PULL", path: "", response_body: "", status: 200}
is_map(map)
is_struct(conv)

URI.decode_query("name=Baloo&type=Brown")


------------------------------- Enum Operatoren:

triple = &(&1 * 3)
triple = fn(x) -> x * 3 end
triple.(10)
Enum.map([1,25,876], triple)
Enum.each(["a", "b", "c", "d"], fn(x) -> IO.puts(x) end)

Enum.sort()
Enum.map()
Enum.find()
Enum.filter()
Enum.reduce()


--------------------------- Loops
Enum.map([1,2,3], fn(x) -> x*3 end)
for x <- [1,2,3], do: x*3
for size <- ["S","M","L"], color <- [:red, :blue], do: {size,color}

---------------------- Pattern Maching Comprehensions
prefs = [ {"Betty", :dog}, {"Bob", :dog}, {"Becky", :cat} ]
for {name, :dog} <- prefs, do: name
for {name, pet_choice} <- prefs, pet_choice == :dog, do: name
dog_lover? = fn(choice) -> choice == :dog end
cat_lover? = fn(choice) -> choice == :cat end
for {name, pet_choice} <- prefs, dog_lover?.(pet_choice), do: name
Enum.map(prefs, fn{x,y} -> [x,cat_lover?.(y)] end)

style = %{"width" => 10, "height" => 20, "border" => "2px"}
style2 = %{width: 20, height: 20}
area = style["width"]*style["height"]
area2 = style2.width * style2.height

style_new=Map.new(style, fn {key, val} -> {String.to_atom(key), val} end)
style_new.border

for {key, val} <- style, into: %{}, do: {String.to_atom(key), val}
for {key,value} <- prefs, value == :dog , into: %{}, do: {String.to_atom(key), Atom.to_string(value)}


------------------------ Servy.BearController.Index Versions
defp bear_item(bear), do: "<li>#{bear.name} - #{bear.type}</li>"
* V1
items =
  Wildthings.list_bears()
  |> Enum.filter( &Bear.is_grizzly/1 )
  |> Enum.sort( &Bear.order_asc_by_name(&1, &2) )
  |> Enum.map(&bear_item/1)
  |> Enum.join
%{conv | status: 200, resp_body: "<ul><li>#{items}</li></ul>"}
* V2
items =
  Wildthings.list_bears()
  |> Enum.filter(fn b ->  Bear.is_grizzly(b) end)
  |> Enum.sort(fn(b1,b2) -> b1.name <= b2.name end )
  |> Enum.map(fn(b) -> bear_item(b) end)
  |> Enum.join
%{conv | status: 200, resp_body: "<ul><li>#{items}</li></ul>"}


"""
