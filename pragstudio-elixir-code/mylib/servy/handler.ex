defmodule Servy.Handler do
  def handle(request) do
    # the functions resolve from the inside out.
    format_response(route(parse(request)))
    # chaining the functions together by using pipe operators
    # request
    # |> parse
    # |> routeiex
    # |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first
        |> String.split(" ")

    #first_line = request |> String.split("\n") |> List.first
    #[method, path, _] = String.split(first_line," ")
    %{ method: method, path: path, resp_body: "" }
  end

  def route(_conv) do
    # TODO: Create a new map that also has the response body:
    _conv = %{ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
  end

  def format_response(_conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
IO.puts request

response = Servy.Handler.handle(request)

IO.puts response


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
#iex> m = %{ method: "GET", path: "/wildthings" } # atoms as keys
#iex> m = %{ "method" => "GET", "path" => "/wildthings" }  # string as keys
#iex> f = %{ a: 1, b: 'asdf', c: [34.4,18.1,24.8] }
#iex> f.c
